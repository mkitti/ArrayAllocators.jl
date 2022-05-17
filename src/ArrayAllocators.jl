"""
    ArrayAllocators

Defines an array allocator interface and concrete array allocators using `malloc`, `calloc`, and memory alignment.

# Examples

```julia
using ArrayAllocators

Array{UInt8}(malloc, 100)
Array{UInt8}(calloc, 1024, 1024)
Array{UInt8}(MemAlign(2^16), (1024, 1024, 16))
```

See also `NumaAllocators`, `SafeByteCalculators`
"""
module ArrayAllocators


import Core: Array

export malloc, calloc

include("ByteCalculators.jl")

using .ByteCalculators

"""
    DefaultByteCalculator

Alias for [`ByteCalculators.CheckedMulByteCalculator`](@ref) representing the
byte calculator used with subtypes of `AbstractArrayAllocator` when one is not
specified.
"""
const DefaultByteCalculator = CheckedMulByteCalculator

export AbstractArrayAllocator, UndefAllocator, MallocAllocator, CallocAllocator
export MemAlign


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

function allocate(alloc::A, ::Type{T}, num_bytes) where {A <: AbstractArrayAllocator, T}
    iszeroinit(A) || isbitstype(T) || throw(ArgumentError("$T is not a bitstype"))
    return Ptr{T}(allocate(alloc, num_bytes))
end
(::Type{A})(args...) where A <: AbstractArrayAllocator = A{DefaultByteCalculator}(args...)
iszeroinit(::Type{A}) where A <: AbstractArrayAllocator = false


"""
    UndefAllocator{B}

Allocate arrays using the builtin `undef` method. The `B` parameter is a `ByteCalculator`
"""
struct UndefAllocator{B} <: AbstractArrayAllocator{B}
end
allocate(::UndefAllocator, num_bytes) = C_NULL
Base.unsafe_wrap(::UndefAllocator, ::Type{ArrayType}, ::Ptr, dims::Dims) where {T, ArrayType <: AbstractArray{T}} = ArrayType(Core.undef, dims)

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

Allocate array using [`Libc.malloc`](https://docs.julialang.org/en/v1/base/libc/#Base.Libc.malloc). This is not meant to be useful
but rather just to prototype the concept for a custom array allocator
concept. This should be similar to using `undef`.

See also https://en.cppreference.com/w/c/memory/malloc .
"""
struct MallocAllocator{B} <: LibcArrayAllocator{B}
end
allocate(::MallocAllocator, num_bytes) = Libc.malloc(num_bytes)


"""
    malloc

[`MallocAllocator`](@ref) singleton instance. `malloc` will only allocate memory. It does not initialize memory is is similar
in use as `undef`. See the type and the [C standard library function](https://en.cppreference.com/w/c/memory/malloc) for details.

# Example

```jldoctest
julia> Array{UInt8}(malloc, 16, 16);

```

"""
const malloc = MallocAllocator()

"""
    CallocAllocator()

Use [`Libc.calloc`](https://docs.julialang.org/en/v1/base/libc/#Base.Libc.calloc) to allocate an array. This is similar to `zeros`, except
that the Libc implementation or the operating system may allocate and
zero the memory in a lazy fashion.

See also https://en.cppreference.com/w/c/memory/calloc .
"""
struct CallocAllocator{B} <: LibcArrayAllocator{B}
end
allocate(::CallocAllocator, num_bytes) = Libc.calloc(num_bytes, 1)
iszeroinit(::Type{A}) where A <: CallocAllocator = true


"""
    calloc

[`CallocAllocator`](@ref) singleton instance. `calloc` will allocate memory and guarantee initialization to `0`.
See the type for details and the [C standard library function](https://en.cppreference.com/w/c/memory/calloc) for further details.

# Example

```jldoctest
julia> A = Array{UInt8}(calloc, 16, 16);

julia> sum(A)
0x0000000000000000
```
"""
const calloc = CallocAllocator()

"""
    MemAlign([alignment::Integer])

Allocate aligned memory. Alias for platform specific implementations.

`alignment` must be a power of 2.

On POSIX systems, `alignment` must be a multiple of `sizeof(Ptr)`.
On Windows, `alignment` must be a multiple of 2^16.

If `alignment` is not specified, it will be set to `min_alignment(MemAlign)`.

`MemAlign` is a constant alias for one the following platform specific implementations.
* POSIX (Linux and macOS): [`POSIX.PosixMemAlign`](@ref)
* Windows: [`Windows.WinMemAlign`](@ref).


"""
MemAlign


"""
    AbstractMemAlign{B} <: AbstractArrayAllocator{B}

Abstract supertype for aligned memory allocators.
"""
abstract type AbstractMemAlign{B} <: AbstractArrayAllocator{B} end

"""
    alignment(alloc::AbstractMemAlign)

Get byte alignment of the AbstractMemAlign array allocator.
"""
alignment(alloc::AbstractMemAlign) = alloc.alignment

"""
    min_alignment(::AbstractMemAlign)

Get the minimum byte alignment of the AbstractMemAlign array allocator.
"""
function min_alignment() end

include("Windows.jl")
include("POSIX.jl")

import .Windows: WinMemAlign
import .POSIX: PosixMemAlign

@static if Sys.iswindows()
    const MemAlign = WinMemAlign
elseif Sys.isunix()
    const MemAlign = PosixMemAlign
end

include("zeros.jl")

end # module ArrayAllocators
