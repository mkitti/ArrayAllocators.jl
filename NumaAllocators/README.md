# NumaAllocators.jl

Extends ArrayAllocators.jl to handle Non-Uniform Memory Access (NUMA) allocation on Windows and Linux.
See the ArrayAllocators.jl documentation for more information.

## Basic Usage
```julia
julia> A = Array{UInt8}(numa(0), 1024, 1024); # Allocate 1 MB Matrix on NUMA Node 0

julia> B = Array{UInt8}(numa(1), 1024, 1024); # Allocate 1 MB Matrix on NUMA Node 1
```
