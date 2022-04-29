```@meta
CurrentModule = NumaAllocators
```

# NumaAllocators

Non-Uniform Memory Access (NUMA) array allocators allow you to allocate memory on specific NUMA nodes.

## Basic Usage

A `NumaAllocator` can be instantiated via `numa(node)` and passed to the `Array` constructor as below.

```julia
julia> using NumaAllocators

julia> a0 = Array{Int8}(numa(0), 1024, 1024);

julia> b0 = Array{Int8}(numa(0), 1024, 1024);

julia> a1 = Array{Int8}(numa(1), 1024, 1024);

julia> b1 = Array{Int8}(numa(1), 1024, 1024);
```

Depending on your processor architecture, some operations may be between NUMA nodes may be faster than others.

```julia
julia> @time fill!(a0, 1);
  0.000374 seconds

julia> @time fill!(b0, 2);
  0.000307 seconds

julia> @time fill!(a1, 3);
  0.000418 seconds

julia> @time fill!(b1, 4);
  0.000383 seconds

julia> @time copyto!(b0, a0);
  0.000439 seconds

julia> @time copyto!(b1, a0);
  0.000287 seconds

julia> @time copyto!(b1, a1);
  0.000376 seconds

julia> @time copyto!(b0, a1);
  0.000455 seconds

julia> current_numa_node()
0

julia> highest_numa_node()
1

julia> versioninfo()
Julia Version 1.7.2
Commit bf53498635 (2022-02-06 15:21 UTC)
Platform Info:
  OS: Windows (x86_64-w64-mingw32)
  CPU: Intel(R) Xeon(R) Gold 5220R CPU @ 2.20GHz
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-12.0.1 (ORCJIT, cascadelake)

```

In the example above, copying 1 MB of data from NUMA node 0 to NUMA node 1 is faster than copying between
memory local to either NUMA node or copying data from NUMA node 1 to NUMA node 0.
