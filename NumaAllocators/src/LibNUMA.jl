"""
    NumaAllocators.LibNUMA

NUMA Support for Linux

See https://github.com/numactl/numactl
"""
module LibNUMA

using ..NumaAllocators: AbstractNumaAllocator
import ArrayAllocators: AbstractArrayAllocator, nbytes, allocate
import ArrayAllocators: lineage_finalizer
    
using NUMA_jll

# Limit exposed symbols on other platforms

@static if ( VERSION >= v"1.6" && NUMA_jll.is_available() ) || isdefined(NUMA_jll, :libnuma)
    const libnuma = NUMA_jll.libnuma
else
    const libnuma = nothing
end

function numa_alloc_onnode(size, node)
    return ccall((:numa_alloc_onnode, libnuma), Ptr{Nothing}, (Csize_t, Cint), size, node)
end

function numa_alloc_local(size)
    return ccall((:numa_alloc_local, libnuma), Ptr{Nothing}, (Csize_t,), size)
end

function numa_free(arr::AbstractArray)
    numa_free(arr, sizeof(arr))
end

function numa_free(mem, size)
    return ccall((:numa_free, libnuma), Nothing, (Ptr{Nothing}, Csize_t), mem, size)
end

function numa_num_task_nodes()
    return ccall((:numa_num_task_nodes, libnuma), Cint, ())
end

function numa_max_node()
    return ccall((:numa_max_node, libnuma), Cint, ())
end

function numa_node_of_cpu(cpu = sched_getcpu())
    return ccall((:numa_node_of_cpu, libnuma), Cint, (Cint,), cpu)
end

function sched_getcpu()
    return ccall(:sched_getcpu, Cint, ())
end

function wrap_numa(::Type{ArrayType}, ptr::Ptr{T}, dims) where {T, ArrayType <: AbstractArray{T}}
    if ptr == C_NULL
        throw(OutOfMemoryError())
    end
    arr = unsafe_wrap(ArrayType, ptr, dims; own = false)
    lineage_finalizer(numa_free, arr)
    return arr
end

abstract type AbstractLibNumaAllocator{B} <: AbstractNumaAllocator{B} end
Base.unsafe_wrap(::AbstractLibNumaAllocator, args...) = wrap_numa(args...)

"""
    LibNumaAllocator{B}

Allocate memory via `numa_alloc_onnode`.

See https://linux.die.net/man/3/numa
"""
struct LibNumaAllocator{B} <: AbstractLibNumaAllocator{B}
    node::Cint
end

function allocate(n::LibNumaAllocator, num_bytes)
    return numa_alloc_onnode(num_bytes, n.node)
end

end # module LibNUMA
