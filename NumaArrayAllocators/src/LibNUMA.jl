module LibNUMA

using ..NumaArrayAllocators: AbstractNumaAllocator
using ArrayAllocators: AbstractArrayAllocator, DefaultByteCalculator, nbytes
using NUMA_jll

const libnuma = NUMA_jll.libnuma

function numa_alloc_onnode(size, node)
    @ccall libnuma.numa_alloc_onnode(size::Csize_t, node::Cint)::Ptr{Nothing}
end

function numa_free(mem, size)
    @ccall libnuma.numa_free(mem::Ptr{nothing}, size::Csize_t)::Nothing
end

function wrap_numa(::Type{ArrayType}, ptr::Ptr{T}, dims) where {T, ArrayType <: AbstractArray{T}}
    if ptr == C_NULL
        throw(OutOfMemoryError())
    end
    arr = unsafe_wrap(ArrayType, ptr, dims; own = false)
    finalizer(numa_free, arr)
    return arr
end

abstract type AbstractLibNumaAllocator{B} <: AbstractNumaAllocator{B} end
Base.unsafe_wrap(::AbstractLibNumaAllocator, args...) = wrap_numa(args...)

"""
    LibNumaAllocator{B}
"""
struct LibNumaAllocator{B} <: AbstractLibNumaAllocator{B}
    node::Cint
end

LibNumaAllocator(node) = LibNumaAllocator{DefaultByteCalculator}(node)
function allocate(n::LibNumaAllocator, num_bytes)
    return numa_alloc_onnode(num_bytes, n.node)
end

#=
function (::Type{ArrayType})(n::AbstractLibNumaAllocator{B}, dims) where {T, B, ArrayType <: AbstractArray{T}}
    num_bytes = nbytes(B{T}(dims))
    ptr = Ptr{T}(numa_alloc_onnode(num_bytes, n.node))
    return wrap_numa(ArrayType, ptr, dims)
end
=#

end # module LibNUMA
