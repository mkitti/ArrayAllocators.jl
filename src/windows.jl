module Windows

using ..ArrayAllocators: AbstractArrayAllocator
using SaferIntegers
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
LPVOID VirtualAllocExNuma(
  [in]           HANDLE hProcess,
  [in, optional] LPVOID lpAddress,
  [in]           SIZE_T dwSize,
  [in]           DWORD  flAllocationType,
  [in]           DWORD  flProtect,
  [in]           DWORD  nndPreferred
);
=#


function VirtualAllocExNuma(hProcess, lpAddress, dwSize, flAllocationType, flProtect, nndPreferred)
    ccall((:VirtualAllocExNuma, kernel32),
        Ptr{Nothing}, (Ptr{Nothing}, Ptr{Nothing}, Csize_t, Culong, Culong, Culong),
        hProcess, lpAddress, dwSize, flAllocationType, flProtect, nndPreferred)
end
function VirtualAllocExNuma(dest_size, numa_node)
    VirtualAllocExNuma(hCurrentProcess, C_NULL, dest_size, MEM_COMMIT_RESERVE, PAGE_READWRITE, numa_node)
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
    VirtualFreeEx(pointer(array))
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

struct WinVirtualAllocator <: AbstractArrayAllocator
end
const virtual = WinVirtualAllocator()
function Array{T}(::WinVirtualAllocator, dims) where T
    size = sizeof(T)
    num = prod(dims)
    num_bytes = num*size
    ptr = Ptr{T}(VirtualAllocEx(num_bytes))
    return wrap_virtual(ptr, dims)
end

struct SafeWinVirtualAllocator <: AbstractArrayAllocator
end

const safe_virtual = SafeWinVirtualAllocator()
function Array{T}(::SafeWinVirtualAllocator, dims) where T
    size = SafeInt(sizeof(T))
    num = prod(SafeInt.(dims))
    num_bytes = num*size
    ptr = Ptr{T}(VirtualAllocEx(num_bytes))
    return wrap_virtual(ptr, dims)
end

struct WinNumaAllocator <: AbstractArrayAllocator
    node::Int
end

function Array{T}(n::WinNumaAllocator, dims) where T
    size = sizeof(T)
    num = prod(dims)
    num_bytes = num*size
    ptr = Ptr{T}(VirtualAllocExNuma(num_bytes, n.node))
    return wrap_virtual(ptr, dims)
end

struct SafeWinNumaAllocator <: AbstractArrayAllocator
    node::Int
end

function Array{T}(n::SafeWinNumaAllocator, dims) where T
    size = SafeInt(sizeof(T))
    num = prod(SafeInt.(dims))
    num_bytes = num*size
    ptr = Ptr{T}(VirtualAllocExNuma(num_bytes, n.node))
    return wrap_virtual(ptr, dims)
end

end
