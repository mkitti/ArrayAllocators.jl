var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = ArrayAllocators","category":"page"},{"location":"#ArrayAllocators","page":"Home","title":"ArrayAllocators","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for ArrayAllocators.","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [ArrayAllocators]","category":"page"},{"location":"#ArrayAllocators.CallocAllocator","page":"Home","title":"ArrayAllocators.CallocAllocator","text":"CallocAllocator\n\nUse Libc.calloc to allocate an array. This is similar to zeros`, except that the Libc implementation or the operating system may allocate and zero the memory in a lazy fashion.\n\n\n\n\n\n","category":"type"},{"location":"#ArrayAllocators.MallocAllocator","page":"Home","title":"ArrayAllocators.MallocAllocator","text":"MallocAllocator()\n\nAllocate array using Libc.malloc. This is not meant to be useful but rather just to prototype the concept for a custom array allocator concept. This should be similar to using undef.\n\n\n\n\n\n","category":"type"},{"location":"#ArrayAllocators.SafeCallocAllocator","page":"Home","title":"ArrayAllocators.SafeCallocAllocator","text":"SafeCallocAllocator\n\nUse SaferIntegers.SafeInt to calculate the number of bytes needed. See CallocAllocator.\n\n\n\n\n\n","category":"type"},{"location":"#ArrayAllocators.SaferMallocAllocator","page":"Home","title":"ArrayAllocators.SaferMallocAllocator","text":"SafeMallocAllocator\n\nUse SaferInteger.SafeInt to calculate the number of bytes needed. See SaferMallocAllocator.\n\n\n\n\n\n","category":"type"},{"location":"#ArrayAllocators.wrap_libc_pointer-Union{Tuple{A}, Tuple{T}, Tuple{Type{A}, Ptr{T}, Any}} where {T, A<:(AbstractArray{T})}","page":"Home","title":"ArrayAllocators.wrap_libc_pointer","text":"wrap_libc_pointer(::Type{A}, ptr::Ptr{T}, dims) where {T, A <: AbstractArray{T}}\nwrap_libc_pointer(ptr::Ptr{T}, dims) where {T, A <: AbstractArray{T}}\n\nChecks to see if ptr is C_NULL for an OutOfMemoryError. Owns the array such that Libc.free is used.\n\n\n\n\n\n","category":"method"}]
}