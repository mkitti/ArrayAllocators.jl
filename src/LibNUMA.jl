module LibNUMA

using NUMA_jll

const libnuma = NUMA_jll.libnuma

struct LibNumaAllocator
    node::Cint
end

function numa_alloc_onnode(size, node)
    @ccall libnuma.numa_alloc_onnode(size::Csize_t, node::Cint)::Ptr{Nothing}
end

function numa_free(mem, size)
    @ccall libnuma.numa_free(mem::Ptr{nothing}, size::Csize_t)::Nothing
end

function wrap_numa(ptr::Ptr{T}, dims) where T
    if ptr == C_NULL
        throw(OutOfMemoryError())
    end
    arr = unsafe_wrap(Array{T}, ptr, dims; own = false)
    finalizer(numa_free, arr)
    return arr
end

function Array{T}(n::LibNumaAllocator, dims) where T
    size = sizeof(T)
    num = prod(dims)
    num_bytes = num*size
    ptr = Ptr{T}(numa_alloc_onnode(num_bytes, n.node))
    return wrap_numa(ptr, dims)
end

end
