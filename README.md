# ArrayAllocators.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://mkitti.github.io/ArrayAllocators.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://mkitti.github.io/ArrayAllocators.jl/dev)
[![Build Status](https://github.com/mkitti/ArrayAllocators.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/mkitti/ArrayAllocators.jl/actions/workflows/CI.yml?query=branch%3Amain)

ArrayAllocators.jl is a Julia language package that provides various methods to allocate memory for arrays. It also implements various ways of calculating the total number of bytes in order to detect integer overflow conditions when multiplying the dimensions of an array and the size of the array elements.

For example, [`calloc`](https://en.cppreference.com/w/c/memory/calloc) is a standard C function that allocates memory while initializing the bytes in the memory to `0`, which may be done lazily by some operating sytems as needed. Contrast this with Julia's `Base.zeros` which eagerly fills sets all the bytes in memory to `0`. This often means that allocating memory via `calloc` may be initially faster than using `Base.zeros`.

The Python package NumPy for example, implements [`numpy.zeros`](https://numpy.org/doc/stable/reference/generated/numpy.zeros.html) with `calloc`.
At times, `numpy.zeros` and Python code using this method may seem to outperform Julia code using `Base.zeros`. See the Discourse link under
the discussion below for further details.

Other examples of specialized array allocation techniques include aligned memory on POSIX systems or virtual allocations on Windows systems.

Multiple processor socket systems may also implement Non-Uniform Memory Access (NUMA) memory architecture. To optimally use the NUMA architecture, memory must be explicitly allocated on a specific NUMA node. The subpackage [NumaAllocators.jl](NumaAllocators) implements this functionality for Windows and Linux operating systems.

`AbstractArrayAllocator` can be provided as first argument when constructing any subtype of `AbstractArray` where `undef` is usually provided.

Any C function that returns a pointer can be wrapped by the `AbstractArrayAllocator` interface by implementing the `allocate` method and overriding
`Base.unsafe_wrap`.

## Installation

```julia
using Pkg
Pkg.add("ArrayAllocators")
```

## Usage

```
julia> using ArrayAllocators

julia> @time zeros(UInt8, 2048, 2048);
  0.000514 seconds (2 allocations: 4.000 MiB)

julia> @time Array{UInt8}(undef, 2048, 2048);
  0.000017 seconds (2 allocations: 4.000 MiB)

julia> @time Array{UInt8}(calloc, 2048, 2048); # Allocates zeros, but is much faster than `Base.zeros`
  0.000015 seconds (2 allocations: 4.000 MiB)

julia> @time Array{UInt8}(calloc, 20480000, typemax(Int64));
ERROR: OverflowError: 20480000 * 9223372036854775807 overflowed for type Int64
...

julia> using NumaAllocators

julia> @time Array{UInt8}(NumaAllocator(0), 2048, 2048);
  0.000010 seconds (2 allocations: 80 bytes)

```

## Subpackages

* [NumaAllocators.jl](NumaAllocators): Allocate memory on Non-Uniform Memory Access (NUMA) nodes
* [SafeByteCaculators.jl](SafeByteCalculators): Implement byte calculations using SaferIntegers.jl to detect integer overflow. Note that a form of integer overflow detection is implemented in ArrayAllocators.jl itself. This package just provides an alternative implementation.

## Discussion

See https://discourse.julialang.org/t/faster-zeros-with-calloc/69860 for discussion about this approach.
