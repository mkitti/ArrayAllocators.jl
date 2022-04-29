"""
    NumaAllocators

Extends `ArrayAllocators` to allocate memory on specific NUMA nodes.

# Examples

```julia
using NumaAllocators

Array{UInt8}(numa(0), 100)
Array{UInt8}(NumaAllocator(1), 100)
```
"""
module NumaAllocators

@static if VERSION >= v"1.3"
    using NUMA_jll
end

using ArrayAllocators: AbstractArrayAllocator

export NumaAllocator, numa
export current_numa_node, highest_numa_node

abstract type AbstractNumaAllocator{B} <: AbstractArrayAllocator{B} end

include("Windows.jl")
include("LibNUMA.jl")

@static if Sys.iswindows()
    import .Windows: WinNumaAllocator

    const NumaAllocator = WinNumaAllocator
elseif ( VERSION >= v"1.6" && NUMA_jll.is_available() ) || isdefined(NUMA_jll, :libnuma)
    import .LibNUMA: LibNumaAllocator

    const NumaAllocator = LibNumaAllocator
end

if @isdefined(NumaAllocator)
    numa(node) = NumaAllocator(node)
end

"""
    NumaAllocator(node)

Cross-platform NUMA allocator

# Example

```jldoctest
julia> using NumaAllocators

julia> Array{UInt8}(NumaAllocator(0), 32, 32);
```
"""
NumaAllocator

"""
    numa(node)

Create a `NumaAllocator` on NUMA node `node`. Short hand for [`NumaAllocator`](@ref) constructor.

# Example

```jldoctest
julia> using NumaAllocators

julia> Array{UInt8}(numa(0), 32, 32);
```
"""
numa

"""
    current_numa_node()::Int

Returns the current NUMA node as an Int
"""
function current_numa_node()::Int
    @static if Sys.iswindows()
        return Int(Windows.GetNumaProcessorNode())
    elseif Sys.islinux()
        return Int(LibNUMA.numa_node_of_cpu())
    else
        error("current_numa_node is not implemented for this platform")
    end
end

"""
    highest_numa_node()::Int

Returns the highest NUMA node as an Int
"""
function highest_numa_node()::Int
    @static if Sys.iswindows()
        return Int(Windows.GetNumaHighestNodeNumber())
    elseif Sys.islinux()
        return Int(LibNUMA.numa_max_node())
    else
        error("highest_numa_node is not implemented for this platform")
    end
end

end
