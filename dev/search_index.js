var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = ArrayAllocators","category":"page"},{"location":"#ArrayAllocators","page":"Home","title":"ArrayAllocators","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for ArrayAllocators.","category":"page"},{"location":"","page":"Home","title":"Home","text":"This Julia package provides mechanisms to allocate arrays beyond that provided in the Base module of Julia.","category":"page"},{"location":"","page":"Home","title":"Home","text":"The instances of the sub types of AbstractArrayAllocators take the place of undef in the Array{T}(undef, dims) invocation. This allows us to take advantage of alternative ways of allocating memory. The allocators take advantage of Base.unsafe_wrap in order to create arrays from pointers. A finalizer is also added for allocators that do not use Libc.free.","category":"page"},{"location":"","page":"Home","title":"Home","text":"The original inspiration for this package is the memory allocator calloc. calloc allocates the memory and guarantees that the memory will be initialized by zeros. By this definition, it would appear equivalent to Base.zeros. However, calloc is potentially able to take advantage of operating system facilities that allocate memory lazily on demand rather than eagerly. Additonally, it may be able to obtain memory from the operating system that has already been initialized by zeros due to security constraints. On many systems, this allocator returns as quickly as malloc, the allocator used by Array{T}(undef, dims). In particular, in Python, numpy.zeros uses calloc, which may at times appear faster than Base.zeros in Julia.","category":"page"},{"location":"","page":"Home","title":"Home","text":"In contrast, Base.zeros allocates memory using malloc and then uses fill! to eagerly and explicitly fill the array with zeros. On some systems, this may be a redudnant operation since the operating system may already know the allocated memory is filled with zeros.","category":"page"},{"location":"","page":"Home","title":"Home","text":"This package makes calloc and other allocators available. Some of these allocators are specific to particular kinds of systems.","category":"page"},{"location":"","page":"Home","title":"Home","text":"One example is allocating on Non-Uniform Memory Access (NUMA) nodes. On a NUMA system, random-access memory (RAM) may be accessible by certain processor cores at lower latency and higher bandwidth than other cores. Thus, it makes sense to allocate memory on particular NUMA nodes. On Linux, this is facilitated by numactl software which includes libnuma. On Windows, NUMA-aware memory allocation is exposed via the Kernel32 memory application programming interface such as via the function VirtualAllocExNuma. This package provides an abstraction over the two libraries.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Another application is memory alignment which may facilitate the use of advanced vector instructions in modern processors.","category":"page"},{"location":"","page":"Home","title":"Home","text":"One other feature of this package is implementation of \"Safe\" allocators. These allocators provide extra protection by detecting integer overflow situations. Integer overflow can occur when multiplying large numbers causing the result to potentially wrap around. Memory allocators may report success after allocating an wrapped around number of bytes. The \"Safe\" allocators use the SaferIntegers to detect integer overflow avoiding this erroneous situation.","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [ArrayAllocators]","category":"page"},{"location":"#ArrayAllocators.calloc","page":"Home","title":"ArrayAllocators.calloc","text":"calloc\n\nCallocAllocator singleton\n\n\n\n\n\n","category":"constant"},{"location":"#ArrayAllocators.malloc","page":"Home","title":"ArrayAllocators.malloc","text":"malloc\n\nMallocAllocator singleton.\n\n\n\n\n\n","category":"constant"},{"location":"#ArrayAllocators.safe_calloc","page":"Home","title":"ArrayAllocators.safe_calloc","text":"safe_calloc\n\nSafeCallocAllocator singleton\n\n\n\n\n\n","category":"constant"},{"location":"#ArrayAllocators.safe_malloc","page":"Home","title":"ArrayAllocators.safe_malloc","text":"safe_malloc\n\nSafeMallocAllocator singleton\n\n\n\n\n\n","category":"constant"},{"location":"#ArrayAllocators.AbstractArrayAllocator","page":"Home","title":"ArrayAllocators.AbstractArrayAllocator","text":"AbstractArrayAllocator\n\nParent abstract type for array allocators. Defines Array{T}(allocator, dims...) where T = Array{T}(allocator, dims)\n\n\n\n\n\n","category":"type"},{"location":"#ArrayAllocators.CallocAllocator","page":"Home","title":"ArrayAllocators.CallocAllocator","text":"CallocAllocator()\n\nUse Libc.calloc to allocate an array. This is similar to zeros, except that the Libc implementation or the operating system may allocate and zero the memory in a lazy fashion.\n\n\n\n\n\n","category":"type"},{"location":"#ArrayAllocators.MallocAllocator","page":"Home","title":"ArrayAllocators.MallocAllocator","text":"MallocAllocator()\n\nAllocate array using Libc.malloc. This is not meant to be useful but rather just to prototype the concept for a custom array allocator concept. This should be similar to using undef.\n\n\n\n\n\n","category":"type"},{"location":"#ArrayAllocators.SafeCallocAllocator","page":"Home","title":"ArrayAllocators.SafeCallocAllocator","text":"SafeCallocAllocator()\n\nUse SaferIntegers.SafeInt to calculate the number of bytes needed. See CallocAllocator.\n\n\n\n\n\n","category":"type"},{"location":"#ArrayAllocators.SaferMallocAllocator","page":"Home","title":"ArrayAllocators.SaferMallocAllocator","text":"SafeMallocAllocator()\n\nUse SaferInteger.SafeInt to calculate the number of bytes needed. See SaferMallocAllocator.\n\n\n\n\n\n","category":"type"},{"location":"#ArrayAllocators.wrap_libc_pointer-Union{Tuple{A}, Tuple{T}, Tuple{Type{A}, Ptr{T}, Any}} where {T, A<:(AbstractArray{T})}","page":"Home","title":"ArrayAllocators.wrap_libc_pointer","text":"wrap_libc_pointer(::Type{A}, ptr::Ptr{T}, dims) where {T, A <: AbstractArray{T}}\nwrap_libc_pointer(ptr::Ptr{T}, dims) where {T, A <: AbstractArray{T}}\n\nChecks to see if ptr is C_NULL for an OutOfMemoryError. Owns the array such that Libc.free is used.\n\n\n\n\n\n","category":"method"}]
}