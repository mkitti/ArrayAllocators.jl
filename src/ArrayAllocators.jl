module ArrayAllocators


import Core: Array

export malloc, calloc

include("ByteCalculators.jl")

using .ByteCalculators

const DefaultByteCalculator = CheckedMulByteCalculator

export AbstractArrayAllocator, UndefArrayAllocator, MallocAllocator, CallocAllocator


"""
    AbstractArrayAllocator{B}

Parent abstract type for array allocators. Parameter `B` is an AbstractByteCalculator
Defines `Array{T}(allocator, dims...) where T = Array{T}(allocator, dims)`
"""
abstract type AbstractArrayAllocator{B} end

# Allocate arrays when the dims are given as arguments rather than as a tuple
function (::Type{ArrayType})(alloc::A, dims...) where {T, ArrayType <: AbstractArray{T}, A <: AbstractArrayAllocator}
    return ArrayType(alloc, dims)
end

function (::Type{ArrayType})(alloc::A, dims) where {T, ArrayType <: AbstractArray{T}, B, A <: AbstractArrayAllocator{B}}
    num_bytes = nbytes(B{T}(dims))
    ptr = allocate(alloc, T, num_bytes)
    return unsafe_wrap(alloc, ArrayType, ptr, dims)
end

function allocate(alloc::AbstractArrayAllocator, ::Type{T}, num_bytes) where T
    return Ptr{T}(allocate(alloc, num_bytes))
end


"""
    UndefArrayAllocator{B}

Allocate arrays using the builtin `undef` method. The `B` parameter is a `ByteCalculator`
"""
struct UndefArrayAllocator{B} <: AbstractArrayAllocator{B}
end
allocate(::UndefArrayAllocator, num_bytes) = nothing
Base.unsafe_wrap(::UndefArrayAllocator, ::Type{ArrayType}, ::Nothing, dims::Dims) where {T, ArrayType <: AbstractArray{T}} = ArrayType(undef, dims)

#=
function (::Type{ArrayType})(::UndefArrayAllocator{B}, dims) where {T, B, ArrayType <: AbstractArray{T}}
    byteCalc = nbytes(B{T}(dims))
    return ArrayType(undef, dims)
end
=#

abstract type LibcArrayAllocator{B} <: AbstractArrayAllocator{B} end

"""
    wrap_libc_pointer(::Type{A}, ptr::Ptr{T}, dims) where {T, A <: AbstractArray{T}}
    wrap_libc_pointer(ptr::Ptr{T}, dims) where {T, A <: AbstractArray{T}}

Checks to see if `ptr` is C_NULL for an OutOfMemoryError.
Owns the array such that `Libc.free` is used.
"""
function wrap_libc_pointer(::Type{A}, ptr::Ptr{T}, dims) where {T, A <: AbstractArray{T}}
    if ptr == C_NULL
        throw(OutOfMemoryError())
    end
    # We use own = true, so we do not need Libc.free explicitly
    arr = unsafe_wrap(A, ptr, dims; own = true)
    return arr
end
wrap_libc_pointer(ptr::Ptr{T}, dims) where T = wrap_libc_pointer(Array{T}, ptr, dims)
Base.unsafe_wrap(alloc::A, args...) where A <: LibcArrayAllocator = wrap_libc_pointer(args...)

"""
    MallocAllocator()

Allocate array using `Libc.malloc`. This is not meant to be useful
but rather just to prototype the concept for a custom array allocator
concept. This should be similar to using `undef`.
"""
struct MallocAllocator{B} <: LibcArrayAllocator{B}
end
allocate(::MallocAllocator, num_bytes) = Libc.malloc(num_bytes)

MallocAllocator() = MallocAllocator{DefaultByteCalculator}()

"""
    malloc

MallocAllocator singleton.

# Example

```jldoctest
julia> Array{UInt8}(malloc, 16, 16);

```

"""
const malloc = MallocAllocator()

#=
function (::Type{ArrayType})(::MallocAllocator{B}, dims) where {B, T, ArrayType <: AbstractArray{T}}
    byteCalc = B{T}(dims)
    ptr = Libc.malloc(nbytes(byteCalc))
    return wrap_libc_pointer(ArrayType, Ptr{T}(ptr), dims)
end
=#

"""
    CallocAllocator()

Use Libc.calloc to allocate an array. This is similar to `zeros`, except
that the Libc implementation or the operating system may allocate and
zero the memory in a lazy fashion.
"""
struct CallocAllocator{B} <: LibcArrayAllocator{B}
end
allocate(::CallocAllocator, num_bytes) = Libc.calloc(num_bytes, 1)


CallocAllocator() = CallocAllocator{DefaultByteCalculator}()

"""
    calloc

CallocAllocator singleton.

# Example

```jldoctest
julia> A = Array{UInt8}(calloc, 16, 16);

julia> sum(A)
0x0000000000000000
```
"""
const calloc = CallocAllocator()

#=
function (::Type{ArrayType})(::CallocAllocator{B}, dims) where {T, B, ArrayType <: AbstractArray{T}}
    byteCalc = B{T}(dims)
    ptr = Libc.calloc(nbytes(byteCalc), 1)
    return wrap_libc_pointer(ArrayType, Ptr{T}(ptr), dims)
end
=#

@static if Sys.iswindows()
    include("Windows.jl")
end

@static if Sys.isunix()
    include("POSIX.jl")
    import .POSIX: MemAlign
    export MemAlign
end

end # module ArrayAllocators
