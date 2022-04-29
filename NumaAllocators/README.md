# NumaAllocators.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://mkitti.github.io/ArrayAllocators.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://mkitti.github.io/ArrayAllocators.jl/dev)
[![Build Status](https://github.com/mkitti/ArrayAllocators.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/mkitti/ArrayAllocators.jl/actions/workflows/CI.yml?query=branch%3Amain)

Extends ArrayAllocators.jl to handle Non-Uniform Memory Access (NUMA) allocation on Windows and Linux.
See the ArrayAllocators.jl documentation for more information.

## Basic Usage
```julia
julia> A = Array{UInt8}(numa(0), 1024, 1024); # Allocate 1 MB Matrix on NUMA Node 0

julia> B = Array{UInt8}(numa(1), 1024, 1024); # Allocate 1 MB Matrix on NUMA Node 1
```
