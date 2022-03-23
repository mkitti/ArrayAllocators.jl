# ArrayAllocators

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://mkitti.github.io/ArrayAllocators.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://mkitti.github.io/ArrayAllocators.jl/dev)
[![Build Status](https://github.com/mkitti/ArrayAllocators.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/mkitti/ArrayAllocators.jl/actions/workflows/CI.yml?query=branch%3Amain)

```
julia> using ArrayAllocators

julia> @time zeros(UInt8, 2048, 2048);
  0.000514 seconds (2 allocations: 4.000 MiB)

julia> @time Array{UInt8}(undef, 2048, 2048);
  0.000017 seconds (2 allocations: 4.000 MiB)

julia> @time Array{UInt8}(calloc, 2048, 2048);
  0.000015 seconds (2 allocations: 4.000 MiB)

julia> @time Array{UInt8}(NumaAllocator(0), 2048, 2048);
  0.000010 seconds (2 allocations: 80 bytes)

julia> @time Array{UInt8}(safe_calloc, 20480000, typemax(Int64));
ERROR: OverflowError: 20480000 * 9223372036854775807 overflowed for type Int64
...
```

See https://discourse.julialang.org/t/faster-zeros-with-calloc/69860 for discussion about this approach.

** This is currently a work in progress. **
