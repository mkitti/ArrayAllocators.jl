"""
    ArrayAllocators.POSIX

Defines ArrayAllocators for POSIX systems such as macOS or Linux.

# Example

```julia
using ArrayAllocators.POSIX

Array{UInt16}(PosixMemAlign(), 1024)
```
"""
module POSIX

using ..ArrayAllocators: AbstractArrayAllocator, wrap_libc_pointer, LibcArrayAllocator
import ..ArrayAllocators: AbstractMemAlign, min_alignment, alignment
import ..ArrayAllocators: allocate
export PosixMemAlign


# Copied from https://github.com/JuliaPerf/BandwidthBenchmark.jl/blob/main/src/allocate.jl
# Copyright (c) 2021 Carsten Bauer <crstnbr@gmail.com> and contributors
# Originating from https://discourse.julialang.org/t/julia-alignas-is-there-a-way-to-specify-the-alignment-of-julia-objects-in-memory/57501/2
# Copyright (c) 2021 Steven G. Johnson

const POSIX_MEMALIGN_MIN_ALIGNMENT = sizeof(Ptr)

function check_alignment(alignment)
    ispow2(alignment) || throw(ArgumentError("$alignment is not a power of 2"))
    alignment ≥ POSIX_MEMALIGN_MIN_ALIGNMENT || throw(ArgumentError("$alignment is not a multiple of $POSIX_MEMALIGN_MIN_ALIGNMENT"))
    return nothing
end

function posix_memalign(alignment, num_bytes)
    ptr = Ref{Ptr{Cvoid}}()
    err = ccall(:posix_memalign, Cint, (Ref{Ptr{Cvoid}}, Csize_t, Csize_t), ptr, alignment, num_bytes)
    iszero(err) || throw(OutOfMemoryError())
    return ptr
end

"""
    PosixMemAlign([alignment::Integer])

Uses `posix_memalign` to allocate aligned memory.
`alignment` must be a power of 2 and larger than `sizeof(Ptr)`.

If `alignment` is provided, it will be set to `min_alignment(PosixMemAlign)`.

# Example

```julia
julia> Array{UInt8}(PosixMemAlign(32), 16, 16);
```
"""
struct PosixMemAlign{B} <: AbstractMemAlign{B}
    alignment::Integer
    function PosixMemAlign{B}(alignment) where B
        check_alignment(alignment)
        return new{B}(alignment)
    end
end

PosixMemAlign() = PosixMemAlign(POSIX_MEMALIGN_MIN_ALIGNMENT)
Base.unsafe_wrap(::PosixMemAlign, args...) = wrap_libc_pointer(args...)
min_alignment(::Type{PosixMemAlign}) = POSIX_MEMALIGN_MIN_ALIGNMENT

allocate(alloc::PosixMemAlign{B}, num_bytes) where B = posix_memalign(alloc.alignment, num_bytes)

end # module POSIX
