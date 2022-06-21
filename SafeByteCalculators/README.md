# SafeByteCalculators

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://mkitti.github.io/ArrayAllocators.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://mkitti.github.io/ArrayAllocators.jl/dev)
[![Build Status](https://github.com/mkitti/ArrayAllocators.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/mkitti/ArrayAllocators.jl/actions/workflows/CI.yml?query=branch%3Amain)

Implements `ArrayAllocators.AbstractByteCalculator` by using `SaferIntegers.jl` in order to detect integer overflow when calculating the number of bytes to allocate.

## Installation

```julia
using Pkg
Pkg.add(url="https://github.com/mkitti/ArrayAllocators.jl", subdir="SafeByteCalculators")
```

Currently, I do have not have plans to register this package. It mainly serves as an example of how to implement a custom `AbstractByteCalculator`.

## Basic usage

```julia
julia> using ArrayAllocators

julia> using SafeByteCalculators

julia> const safe_malloc = MallocAllocator{SafeByteCalculator}()
MallocAllocator{SafeByteCalculator}()

julia> A = Array{UInt8}(safe_malloc, 1024, 1024);

julia> A = Array{UInt8}(safe_malloc, 1024, typemax(Int));
ERROR: OverflowError: 1024 * 9223372036854775807 overflowed for type Int64
```

## Documentation

See the ArrayAllocators.jl [documentation](https://mkitti.github.io/ArrayAllocators.jl) for more information.

## License

Per [LICENSE](LICENSE), SafeByteCalculators.jl is licensed under the MIT License.
