```@meta
CurrentModule = ArrayAllocators
```

# ArrayAllocators

Documentation for [ArrayAllocators](https://github.com/mkitti/ArrayAllocators.jl).

This Julia package provides mechanisms to allocate arrays beyond that provided in the `Base` module of Julia.

The instances of the sub types of `AbstractArrayAllocators` take the place of `undef` in the `Array{T}(undef, dims)` invocation.
This allows us to take advantage of alternative ways of allocating memory. The allocators take advantage of `Base.unsafe_wrap`
in order to create arrays from pointers. A finalizer is also added for allocators that do not use `Libc.free`.

The original inspiration for this package is the memory allocator [`calloc`](https://en.cppreference.com/w/c/memory/calloc).
`calloc` allocates the memory and guarantees that the memory will be initialized by zeros. By this definition, it would appear
equivalent to `Base.zeros`. However, `calloc` is potentially able to take advantage of operating system facilities that allocate
memory lazily on demand rather than eagerly. Additonally, it may be able to obtain memory from the operating system that has
already been initialized by zeros due to security constraints. On many systems, this allocator returns as quickly as `malloc`,
the allocator used by `Array{T}(undef, dims)`. In particular, in Python, [`numpy.zeros`](https://github.com/juliantaylor/numpy/commit/d271d977bdfb977959db1ff26956666f3836b56b) uses `calloc`, which may at times appear faster than `Base.zeros` in Julia.

In contrast, `Base.zeros` allocates memory using `malloc` and then uses `fill!` to eagerly and explicitly fill the array with zeros.
On some systems, this may be a redudnant operation since the operating system may already know the allocated memory is filled with zeros.

This package makes `calloc` and other allocators available. Some of these allocators are specific to particular kinds of systems.

One example is allocating on Non-Uniform Memory Access (NUMA) nodes. On a NUMA system, random-access memory (RAM) may be accessible
by certain processor cores at lower latency and higher bandwidth than other cores. Thus, it makes sense to allocate memory on particular
NUMA nodes. On Linux, this is facilitated by [`numactl`](https://github.com/numactl/numactl) software which includes `libnuma`.
On Windows, NUMA-aware memory allocation is exposed via the Kernel32 memory application programming interface such as via the function
[`VirtualAllocExNuma`](https://docs.microsoft.com/en-us/windows/win32/api/memoryapi/nf-memoryapi-virtualallocexnuma`). This package
provides an abstraction over the two libraries.

Another application is memory alignment which may facilitate the use of advanced vector instructions in modern processors.

One other feature of this package is implementation of "Safe" allocators. These allocators provide extra protection by detecting
integer overflow situations. Integer overflow can occur when multiplying large numbers causing the result to potentially wrap around.
Memory allocators may report success after allocating an wrapped around number of bytes. The "Safe" allocators use the
[`SaferIntegers`](https://github.com/JeffreySarnoff/SaferIntegers.jl) to detect integer overflow avoiding this erroneous situation.

```@index
```

```@autodocs
Modules = [ArrayAllocators]
```
