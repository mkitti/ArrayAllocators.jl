module Windows

import ..ArrayAllocators: AbstractArrayAllocator, nbytes, allocate
import ..ArrayAllocators: AbstractMemAlign, min_alignment, alignment
import Base: Array

export WinMemAlign

const hCurrentProcess = ccall((:GetCurrentProcess, "kernel32"), Ptr{Nothing}, ())

const kernel32 = "kernel32"
const kernelbase = "kernelbase"
const MEM_COMMIT      = 0x00001000
const MEM_RESERVE     = 0x00002000
const MEM_RESET       = 0x00080000
const MEM_RESET_UNDO  = 0x10000000
const MEM_LARGE_PAGES = 0x20000000
const MEM_PHYSICAL    = 0x00400000
const MEM_TOP_DOWN    = 0x00100000

const MEM_COMMIT_RESERVE = MEM_COMMIT | MEM_RESERVE

const PAGE_READWRITE = 0x04

const MEM_DECOMMIT = 0x00004000
const MEM_RELEASE  = 0x00008000

const DWORD = Culong

abstract type MemExtendedParameterType end

struct MemAddressRequirements
    lowestStartingAddress::Ptr{Nothing}
    highestStartingAddress::Ptr{Nothing}
    alignment::Csize_t
end
MemAddressRequirements(alignment) = MemAddressRequirements(C_NULL, C_NULL, alignment)

struct MemExtendedParameterAddressRequirements <: MemExtendedParameterType
    type::UInt64
    requirements::Base.RefValue{MemAddressRequirements}
    function MemExtendedParameterAddressRequirements(requirements)
        new(1, Ref(requirements))
    end
end

struct _MemExtendedParameterAddressRequirements
    type::UInt64
    pointer::Ptr{MemAddressRequirements}
end

function Base.convert(::Type{_MemExtendedParameterAddressRequirements}, p::MemExtendedParameterAddressRequirements)
    r = Ref(p)
    _MemExtendedParameterAddressRequirements(p.type, pointer_from_objref(p.requirements))
end

#=
LPVOID VirtualAllocEx(
  [in]           HANDLE hProcess,
  [in, optional] LPVOID lpAddress,
  [in]           SIZE_T dwSize,
  [in]           DWORD  flAllocationType,
  [in]           DWORD  flProtect
);
=#
function VirtualAllocEx(hProcess, lpAddress, dwSize, flAllocationType, flProtect)
    ccall((:VirtualAllocEx, kernel32), Ptr{Nothing},
        (Ptr{Nothing}, Ptr{Nothing}, Csize_t, DWORD, DWORD),
        hProcess, lpAddress, dwSize, flAllocationType, flProtect
        )
end
function VirtualAllocEx(dwSize)
    VirtualAllocEx(hCurrentProcess, C_NULL, dwSize, MEM_COMMIT_RESERVE, PAGE_READWRITE)
end

#=
PVOID VirtualAlloc2(
  [in, optional]      HANDLE                 Process,
  [in, optional]      PVOID                  BaseAddress,
  [in]                SIZE_T                 Size,
  [in]                ULONG                  AllocationType,
  [in]                ULONG                  PageProtection,
  [in, out, optional] MEM_EXTENDED_PARAMETER *ExtendedParameters,
  [in]                ULONG                  ParameterCount
);
=#
# https://docs.microsoft.com/en-us/windows/win32/api/memoryapi/nf-memoryapi-virtualalloc2
function VirtualAlloc2(Process, BaseAddress, Size, AllocationType, PageProtection, ExtendedParameters, ParameterCount)
    # Docs say 
    ccall((:VirtualAlloc2, kernelbase), Ptr{Nothing},
          (Ptr{Nothing}, Ptr{Nothing}, Csize_t, Culong, Culong, Ptr{Nothing}, Culong),
          Process, BaseAddress, Size, AllocationType, PageProtection, ExtendedParameters, ParameterCount
         )
end
function VirtualAlloc2(Process, BaseAddress, Size, AllocationType, PageProtection, ParameterCount)
    VirtualAlloc2(Process, BaseAddress, Size, AllocationType, PageProtection, C_NULL, ParameterCount)
end


function win_memalign(alignment, num_bytes; lowestStartingAddress::Ptr{Nothing} = C_NULL, highestStartingAddress::Ptr{Nothing} = C_NULL)
    reqs = MemAddressRequirements(lowestStartingAddress, highestStartingAddress, alignment)
    pr = MemExtendedParameterAddressRequirements(reqs)
    p = Ref{_MemExtendedParameterAddressRequirements}(pr)
    GC.@preserve reqs pr p begin
        ptr = VirtualAlloc2(hCurrentProcess, C_NULL, num_bytes, MEM_COMMIT_RESERVE, PAGE_READWRITE, p, 1)
    end
    return ptr
end

const MIN_ALIGNMENT = 2^16
function check_alignment(alignment)
    ispow2(alignment) || throw(ArgumentError("Alignment must be a power of 2"))
    alignment ≥ MIN_ALIGNMENT || throw(ArgumentError("Alignment must be a multiple of $(MIN_ALIGNMENT)"))
    return nothing
end

#=
BOOL VirtualFreeEx(
  [in] HANDLE hProcess,
  [in] LPVOID lpAddress,
  [in] SIZE_T dwSize,
  [in] DWORD  dwFreeType
);
=#

const BOOL = Cint

function VirtualFreeEx(hProcess, lpAddress, dwSize, dwFreeType)
    ccall((:VirtualFreeEx, kernel32),
        BOOL, (Ptr{Nothing}, Ptr{Nothing}, Csize_t, DWORD),
        hProcess, lpAddress, dwSize, dwFreeType
    )
end
function VirtualFreeEx(lpAddress)
    VirtualFreeEx(hCurrentProcess, lpAddress, 0, MEM_RELEASE)
end

function virtual_free(array::Array{T}) where T
    VirtualFreeEx(array)
end

function wrap_virtual(::Type{A}, ptr::Ptr{T}, dims) where {T, A <: AbstractArray{T}}
    if ptr == C_NULL
        throw(OutOfMemoryError())
    end
    arr = unsafe_wrap(A, ptr, dims; own = false)
    finalizer(virtual_free, arr)
    return arr
end
wrap_virtual(ptr::Ptr{T}, dims) where T = wrap_virtual(Array{T}, ptr, dims)

# == AbstractWinVirtualAllocator == #

abstract type AbstractWinVirtualAllocator{B} <: AbstractArrayAllocator{B} end
allocate(::AbstractWinVirtualAllocator, num_bytes) =  VirtualAllocEx(num_bytes)
Base.unsafe_wrap(::AbstractWinVirtualAllocator, args...) = wrap_virtual(args...)

# == WinVirtualAllocator == #

struct WinVirtualAllocator{B} <: AbstractWinVirtualAllocator{B}
end

const virtual = WinVirtualAllocator()

# == WindowsMemAlign == #

struct WinMemAlign{B} <: AbstractMemAlign{B}
    alignment::Int
    lowestStartingAddress::Ptr{Nothing}
    highestStartingAddress::Ptr{Nothing}
    function WinMemAlign{B}(alignment, lowestStartingAddress = C_NULL, highestStartingAddress = C_NULL) where B
        check_alignment(alignment)
        return new{B}(
            alignment,
            reinterpret(Ptr{Nothing}, lowestStartingAddress),
            reinterpret(Ptr{Nothing}, highestStartingAddress)
        )
    end
end
WinMemAlign() = WinMemAlign(MIN_ALIGNMENT)
allocate(alloc::WinMemAlign, num_bytes) = win_memalign(alloc.alignment, num_bytes; alloc.lowestStartingAddress, alloc.highestStartingAddress)
Base.unsafe_wrap(::WinMemAlign, args...) =  wrap_virtual(args...)
min_alignment(::WinMemAlign) = MIN_ALIGNMENT


end # module Windows
