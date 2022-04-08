module NumaArrayAllocators

@static if VERSION >= v"1.3"
    using NUMA_jll
end

using ArrayAllocators: AbstractArrayAllocator

export NumaAllocator, numa

abstract type AbstractNumaAllocator{B} <: AbstractArrayAllocator{B} end

"""
    NumaAllocator(node)

Cross-platform NUMA allocator

# Example

```jldoctest
julia> Array{UInt8}(NumaAllocator(0), 32, 32)
32×32 Matrix{UInt8}:
...
```
"""
NumaAllocator


@static if Sys.iswindows()
    include("Windows.jl")
    import .Windows: WinNumaAllocator

    const NumaAllocator = WinNumaAllocator
elseif VERSION >= v"1.3" && NUMA_jll.is_available()
    include("LibNUMA.jl")
    import .LibNUMA: LibNumaAllocator

    const NumaAllocator = LibNumaAllocator
end

if @isdefined(NumaAllocator)
    numa(node) = NumaAllocator(node)
end

end
