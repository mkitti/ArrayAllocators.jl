module POSIX

using ..ArrayAllocators: AbstractArrayAllocator, wrap_libc_pointer
export MemAlign

# Copied from https://github.com/JuliaPerf/BandwidthBenchmark.jl/blob/main/src/allocate.jl
struct MemAlign <: AbstractArrayAllocator
    alignment::Integer
    function MemAlign(alignment)
        ispow2(alignment) || throw(ArgumentError("$alignment is not a power of 2"))
        alignment ≥ sizeof(Int) || throw(ArgumentError("$alignment is not a multiple of $(sizeof(T))"))
        return new(alignment)
    end
end

function Array{T}(alloc::MemAlign, dims) where T
    isbitstype(T) || throw(ArgumentError("$T is not a bitstype"))
    p = Ref{Ptr{T}}()
    n = sizeof(T) * prod(dims)
    err = ccall(:posix_memalign, Cint, (Ref{Ptr{T}}, Csize_t, Csize_t), p, alloc.alignment, n)
    iszero(err) || throw(OutOfMemoryError())
    return wrap_libc_pointer(p[], dims)
end

end
