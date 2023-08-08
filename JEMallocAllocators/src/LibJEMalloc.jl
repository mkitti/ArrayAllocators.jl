module LibJEMalloc

using jemalloc_jll

const libjemalloc = jemalloc_jll.libjemalloc

# Standard API

"""
    malloc(size)

The malloc() function allocates size bytes of uninitialized memory. The allocated space is suitably aligned (after possible pointer coercion) for storage of any type of object.
"""
function malloc(size)
    @ccall libjemalloc.malloc(size::Csize_t)::Ptr{Nothing}
end

"""
    calloc(number, size)

The calloc() function allocates space for number objects, each size bytes in length. The result is identical to calling malloc() with an argument of number * size, with the exception that the allocated memory is explicitly initialized to zero bytes.
"""
function calloc(number, size)
    @ccall libjemalloc.calloc(number::Csize_t, size::Csize_t)::Ptr{Nothing}
end

"""
    posix_memalign(ptr, alignment, size)

The posix_memalign() function allocates size bytes of memory such that the allocation's base address is a multiple of alignment, and returns the allocation in the value pointed to by ptr. The requested alignment must be a power of 2 at least as large as sizeof(void *).
"""
function posix_memalign(ptr, alignment, size)
    @ccall libjemalloc.posix_memalign(
        ptr::Ptr{Ptr{Nothing}},
        alignment::Csize_t,
        size::Csize_t
    )::Cint
end

"""
    aligned_alloc(alignment, size)

The aligned_alloc() function allocates size bytes of memory such that the allocation's base address is a multiple of alignment. The requested alignment must be a power of 2. Behavior is undefined if size is not an integral multiple of alignment.
"""
function aligned_alloc(alignment::Csize_t, size::Csize_t)
    @ccall libjemalloc.aligned_alloc(
        alignment::Csize_t,
        size::Csize_t
    )::Ptr{Nothing}
end

"""
    realloc(ptr, size)

The realloc() function changes the size of the previously allocated memory referenced by ptr to size bytes. The contents of the memory are unchanged up to the lesser of the new and old sizes. If the new size is larger, the contents of the newly allocated portion of the memory are undefined. Upon success, the memory referenced by ptr is freed and a pointer to the newly allocated memory is returned. Note that realloc() may move the memory allocation, resulting in a different return value than ptr. If ptr is NULL, the realloc() function behaves identically to malloc() for the specified size.
"""
function realloc(ptr, size)
    @ccall libjemalloc.realloc(ptr::Ptr{Nothing}, size::Csize_t)::Ptr{Nothing}
end

"""
    free(ptr::Ptr{Nothing})::Nothing

The free() function causes the allocated memory referenced by ptr to be made available for future allocations. If ptr is NULL, no action occurs.
"""
function free(ptr)
    @ccall libjemalloc.free(ptr::Ptr{Nothing})::Nothing
end

# Non-standard API

function mallocx(size, flags)
    @ccall libjemalloc.mallocx(size::Csize_t, flags::Cint)::Ptr{Nothing}
end
function rallocx(ptr, size, flags)
    @ccall libjemalloc.rallocx(
        ptr::Ptr{Nothing},
        size::Csize_t,
        flags::Cint
    )::Ptr{Nothing}
end
function xallocx(ptr, size, extra, flags)
    @ccall libjemalloc.xallocx(
        ptr::Ptr{Nothing},
        size::Csize_t,
        extra::Csize_t,
        flags::Cint
    )::Ptr{Nothing}
end
function sallocx(ptr, flags)
    @ccall libjemalloc.sallocx(ptr::Ptr{Nothing}, flags::Cint)::Ptr{Nothing}
end
function dallocx(ptr, flags)
    @ccall libjemalloc.dallocx(ptr::Ptr{Nothing}, flags::Cint)::Ptr{Nothing}
end
function sdallocx(ptr, size, flags)
    @ccall libjemalloc.sdallocx(
        ptr::Ptr{Nothing},
        size::Csize_t,
        flags::Cint
    )::Ptr{Nothing}
end
function nallocx(size, flags)
    @ccall libjemalloc.nallocx(size::Csize_t, flags::Cint)::Ptr{Nothing}
end

function mallctl(name, oldp, oldlenp, newp, newlen)
    @ccall libjemalloc.mallctl(
        name::Cstring,
        oldp::Ptr{Nothing},
        oldlenp::Ptr{Csize_t},
        newp::Ptr{Nothing},
        newlen::Csize_t
    )::Cint
end

function mallctlnametomib(name, mibp, miblenp)
    @ccall libjemalloc.mallctlnametomib(
        name::Cstring,
        mibp::Ptr{Csize_t},
        miblenp::Ptr{Csize_t}
    )::Cint
end

function mallctlbymib(mib, miblen, oldp, oldlenp, newp, newlenp)
    @ccall libjemalloc.mallctlbymib(
        mib::Ptr{Csize_t},
        miblen::Csize_t,
        oldp::Ptr{Nothing},
        oldlenp::Ptr{Csize_t},
        newp::Ptr{Nothing},
        newlen::Csize_t
    )::Cint
end

function malloc_stats_print(write_cb, cbopaque, opts)
    @ccall libjemalloc.malloc_stats_print(
        write_cb::Ptr{Nothing},
        cbopaque::Ptr{Nothing},
        opts::String
    )::Nothing
end

function malloc_usable_size(ptr)
    @ccall libjemalloc.malloc_usable_size(
        ptr::Ptr{Nothing}
    )::Csize_t
end

end
