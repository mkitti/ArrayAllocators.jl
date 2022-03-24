module ArrayAllocators

using SaferIntegers
@static if VERSION >= v"1.3"
    using NUMA_jll
end

import Core: Array

export malloc, safe_malloc
export calloc, safe_calloc

"""
    AbstractArrayAllocator

Parent abstract type for array allocators.
Defines `Array{T}(allocator, dims...) where T = Array{T}(allocator, dims)`
"""
abstract type AbstractArrayAllocator end

function Array{T}(alloc::A, dims...) where {A <: AbstractArrayAllocator, T}
    return Array{T}(alloc, dims)
end

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
    arr = unsafe_wrap(A, ptr, dims; own = true)
    # We use own = true above
    # finalizer(f->Libc.free(pointer(f)), arr)
    return arr
end
wrap_libc_pointer(ptr::Ptr{T}, dims) where T = wrap_libc_pointer(Array{T}, ptr, dims)

abstract type AbstractMallocAllocator <: AbstractArrayAllocator end

"""
    MallocAllocator()

Allocate array using `Libc.malloc`. This is not meant to be useful
but rather just to prototype the concept for a custom array allocator
concept. This should be similar to using `undef`.
"""
struct MallocAllocator <: AbstractMallocAllocator
end

"""
    malloc

MallocAllocator singleton.
"""
const malloc = MallocAllocator()
function Array{T}(::MallocAllocator, dims) where T
    ptr = Libc.malloc(sizeof(T) * prod(dims))
    return wrap_libc_pointer(Ptr{T}(ptr), dims)
end

"""
    SafeMallocAllocator()

Use SaferInteger.SafeInt to calculate the number of bytes needed.
See [`SaferMallocAllocator`](@ref).
"""
struct SaferMallocAllocator <: AbstractMallocAllocator
end

"""
    safe_malloc

SafeMallocAllocator singleton
"""
const safe_malloc = SaferMallocAllocator()
function Array{T}(::SaferMallocAllocator, dims) where T
    product = SafeInt(sizeof(T)) * prod(SafeInt.(dims))
    ptr = Libc.malloc(product)
    return wrap_libc_pointer(Ptr{T}(ptr), dims)
end

abstract type AbstractCallocAllocator <: AbstractArrayAllocator end

"""
    CallocAllocator()

Use Libc.calloc to allocate an array. This is similar to `zeros`, except
that the Libc implementation or the operating system may allocate and
zero the memory in a lazy fashion.
"""
struct CallocAllocator <: AbstractCallocAllocator
end

"""
    calloc

CallocAllocator singleton
"""
const calloc = CallocAllocator()
function Array{T}(::CallocAllocator, dims) where T
    # prod could still overflow
    num = prod(dims)
    size = sizeof(T)
    if num > typemax(typeof(size)) ÷ size
        throw(OverflowError("Dims and element size will cause an overflow."))
    end
    ptr = Libc.calloc(num, size)
    return wrap_libc_pointer(Ptr{T}(ptr), dims)
end

"""
    SafeCallocAllocator()

Use SaferIntegers.SafeInt to calculate the number of bytes needed.
See [`CallocAllocator`](@ref).
"""
struct SafeCallocAllocator <: AbstractCallocAllocator
end
"""
    safe_calloc

SafeCallocAllocator singleton
"""
const safe_calloc = SafeCallocAllocator()
function Array{T}(::SafeCallocAllocator, dims) where T
    # prod could still overflow
    num = prod(SafeInt.(dims))
    size = SafeInt(sizeof(T))
    product = num*size
    ptr = Libc.calloc(product, 1)
    return wrap_libc_pointer(Ptr{T}(ptr), dims)
end

@static if Sys.iswindows()
    include("windows.jl")
    import .Windows: WinNumaAllocator

    """
        NumaAllocator(node)

    Cross-platform NUMA allocator
    """
    const NumaAllocator = WinNumaAllocator
    export NumaAllocator
elseif VERSION >= v"1.3" && NUMA_jll.is_available()
    include("LibNUMA.jl")
    import .LibNUMA: LibNumaAllocator

    """
        NumaAllocator(node)

    Cross-platform NUMA allocator
    """
    const NumaAllocator = LibNumaAllocator
    export NumaAllocator
end

@static if Sys.isunix()
    include("posix.jl")
    import .POSIX: MemAlign
    export MemAlign
end

end # module ArrayAllocators