module LibNUMA

using ..NumaArrayAllocators: AbstractNumaAllocator
import ArrayAllocators: AbstractArrayAllocator, DefaultByteCalculator, nbytes, allocate
using NUMA_jll

const libnuma = NUMA_jll.libnuma

function numa_alloc_onnode(size, node)
    return ccall((libnuma, :numa_alloc_onnode), Ptr{Nothing}, (Csize_t, Cint), size, node)
end

function numa_free(arr::AbstractArray)
    numa_free(arr, sizeof(arr))
end

function numa_free(mem, size)
    return ccall((libnuma, :numa_free), Nothing, (Ptr{Nothing}, Csize_t), mem, size)
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
