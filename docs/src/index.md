```@meta
CurrentModule = ArrayAllocators
```

# ArrayAllocators

*Documentation for [ArrayAllocators](https://github.com/mkitti/ArrayAllocators.jl).*

# Introduction

This Julia package provides mechanisms to allocate arrays beyond that provided in the `Base` module of Julia.

The instances of the sub types of [`AbstractArrayAllocator`](@ref) take the place of `undef` in the `Array{T}(undef, dims)` invocation.
This allows us to take advantage of alternative ways of allocating memory. The allocators take advantage of `Base.unsafe_wrap`
in order to create arrays from pointers. A finalizer is also added for allocators that do not use `Libc.free`.

In the base `ArrayAllocators` package, the following allocators are provided.
* [`calloc`](@ref)
* [`malloc`](@ref)
* [`MemAlign(alignment)`](@ref MemAlign)

An extension for use with Non-Uniform Memory Access allocations is available via the subpackage [NumaAllocators.jl](@ref NumaAllocators).

## Example Basic Usage

Each of the methods below allocate 1 MiB of memory. Using `undef` as the first argument allocate uninitialized memory. The values are not guaranteed to be `0` or any other value.

In `Base`, the method `zeros` can be used to explicitly fill the memory with zeros. This is equivalent to using `fill!(..., 0)`. Using `calloc` guarantees the values will be `0`, yet is often as fast as using
`undef` initialization.

```julia
julia> using ArrayAllocators

julia> @time U = Array{Int8}(undef, 1024, 1024);
  0.000019 seconds (2 allocations: 1.000 MiB)

julia> @time Z1 = zeros(Int8, 1024, 1024);
  0.000327 seconds (2 allocations: 1.000 MiB)

julia> @time Z2 = fill!(Array{UInt8}(undef, 1024, 1024), 0);
  0.000301 seconds (2 allocations: 1.000 MiB)

julia> @time C = Array{Int8}(calloc, 1024, 1024);
  0.000020 seconds (4 allocations: 1.000 MiB)

julia> sum(C)
0
```

## Caveats

Above `calloc` appears to be much faster than `zeros` at generating an array full of `0`s. However, some
of the array created with `zeros` has already been fully allocated. The array allocated with `calloc` take
longer to initialize since the operating system may have deferred the actual allocation of memory.

```julia
julia> @time Z = zeros(Int8, 1024, 1024);
  0.000324 seconds (2 allocations: 1.000 MiB)

julia> @time fill!(Z, 1);
  0.000138 seconds

julia> @time fill!(Z, 2);
  0.000136 seconds

julia> @time U = Array{Int8}(calloc, 1024, 1024);
  0.000020 seconds (4 allocations: 1.000 MiB)

julia> @time fill!(U, 1);
  0.000349 seconds

julia> @time fill!(U, 2);
  0.000136 seconds
```
