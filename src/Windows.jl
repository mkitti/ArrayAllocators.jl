module Windows

import ..ArrayAllocators: AbstractArrayAllocator, DefaultByteCalculator, nbytes, allocate
import Base: Array

const hCurrentProcess = ccall((:GetCurrentProcess, "kernel32"), Ptr{Nothing}, ())

const kernel32 = "kernel32"
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

abstract type AbstractWinVirtualAllocator{B} <: AbstractArrayAllocator{B} end
allocate(::AbstractWinVirtualAllocator, num_bytes) =  VirtualAllocEx(num_bytes)
Base.unsafe_wrap(::AbstractWinVirtualAllocator, args...) = wrap_virtual(args...)

struct WinVirtualAllocator{B} <: AbstractWinVirtualAllocator{B}
end
WinVirtualAllocator() = WinVirtualAllocator{DefaultByteCalculator}()

const virtual = WinVirtualAllocator()

end # module Windows
