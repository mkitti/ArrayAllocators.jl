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



end
