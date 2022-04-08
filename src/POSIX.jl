module POSIX

using ..ArrayAllocators: AbstractArrayAllocator, wrap_libc_pointer, DefaultByteCalculator, LibcArrayAllocator
export MemAlign

abstract type AbstractMemAlign{B} <: LibcArrayAllocator{B} end

# Copied from https://github.com/JuliaPerf/BandwidthBenchmark.jl/blob/main/src/allocate.jl
# Copyright (c) 2021 Carsten Bauer <crstnbr@gmail.com> and contributors
"""
    MemAlign(alignment::Integer)

Use `posix_memalign` to allocate aligned memory.
`alignment` must be a power of 2 and larger than `sizeof(Int)`

# Example

```julia
julia> Array{UInt8}(MemAlign(32), 16, 16)
64×64 Matrix{UInt8}:
...
```
"""
function check_alignment(alignment)
    ispow2(alignment) || throw(ArgumentError("$alignment is not a power of 2"))
    alignment ≥ sizeof(Int) || throw(ArgumentError("$alignment is not a multiple of $(sizeof(T))"))
    return nothing
end

struct MemAlign{B} <: AbstractMemAlign{B}
    alignment::Integer
    function MemAlign{B}(alignment)
        check_alignment(alignment)
        return new{B}(alignment)
    end
end

MemAlign(alignment) = MemAlign{DefaultByteCalculator}(alignment)

function allocate(alloc::MemAlign{B}, ::Type{T}, num_bytes)
    isbitstype(T) || throw(ArgumentError("$T is not a bitstype"))
    p = Ref{Ptr{T}}()
    err = ccall(:posix_memalign, Cint, (Ref{Ptr{T}}, Csize_t, Csize_t), p, alloc.alignment, num_bytes)
    iszero(err) || throw(OutOfMemoryError())
    return p[]
end

#=
function (::Type{ArrayType})(alloc::MemAlign{B}, dims) where {T, B, ArrayType <: AbstractArray{T}}
    isbitstype(T) || throw(ArgumentError("$T is not a bitstype"))
    p = Ref{Ptr{T}}()
    n = nbytes(B{T}(dims))
    err = ccall(:posix_memalign, Cint, (Ref{Ptr{T}}, Csize_t, Csize_t), p, alloc.alignment, n)
    iszero(err) || throw(OutOfMemoryError())
    return wrap_libc_pointer(p[], dims)
end
=#

end # module POSIX
