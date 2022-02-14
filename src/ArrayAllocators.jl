module ArrayAllocators

using SaferIntegers, NUMA_jll

import Core: Array

abstract type AbstractArrayAllocator end

function Array{T}(alloc::A, dims...) where {A <: AbstractArrayAllocator, T}
    return Array{T}(alloc, dims)
end

"""
    wrap_libc_pointer(ptr::Ptr{T})

Checks to see if `ptr` is C_NULL for an OutOfMemoryError.
Owns the array such that `Libc.free` is used.
"""
function wrap_libc_pointer(ptr::Ptr{T}, dims) where T
    if ptr == C_NULL
        throw(OutOfMemoryError())
    end
    arr = unsafe_wrap(Array{T}, ptr, dims; own = true)
    # We use own = true above
    # finalizer(f->Libc.free(pointer(f)), arr)
    return arr
end

abstract type AbstractMallocAllocator <: AbstractArrayAllocator end

"""
    MallocAllocator()

Allocate array using `Libc.malloc`. This is not meant to be useful
but rather just to prototype the concept for a custom array allocator
concept. This should be similar to using `undef`.
"""
struct MallocAllocator <: AbstractMallocAllocator
end
const malloc = MallocAllocator()
function Array{T}(::MallocAllocator, dims) where T
    ptr = Libc.malloc(sizeof(T) * prod(dims))
    return wrap_libc_pointer(Ptr{T}(ptr), dims)
end

"""
    SafeMallocAllocator

Use SaferInteger.SafeInt to calculate the number of bytes needed.
See [`SaferMallocAllocator`](@ref).
"""
struct SaferMallocAllocator <: AbstractMallocAllocator
end
const safe_malloc = SaferMallocAllocator()
function Array{T}(::SaferMallocAllocator, dims) where T
    product = SafeInt(sizeof(T)) * prod(SafeInt.(dims))
    ptr = Libc.malloc(product)
    return wrap_libc_pointer(Ptr{T}(ptr), dims)
end

abstract type AbstractCallocAllocator <: AbstractArrayAllocator end

"""
    CallocAllocator

Use Libc.calloc to allocate an array. This is similar to `zeros``, except
that the Libc implementation or the operating system may allocate and
zero the memory in a lazy fashion.
"""
struct CallocAllocator <: AbstractCallocAllocator
end
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
    SafeCallocAllocator

Use SaferIntegers.SafeInt to calculate the number of bytes needed.
See [`CallocAllocator`](@ref).
"""
struct SafeCallocAllocator <: AbstractCallocAllocator
end
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
    const NumaAllocator = WinNumaAllocator
end

@static if NUMA_jll.is_available()
    include("libnuma.jl")
end

end # module ArrayAllocators
