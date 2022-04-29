"""
    NumaAllocators.Windows

NUMA support for Windows.

See also https://docs.microsoft.com/en-us/windows/win32/api/memoryapi/nf-memoryapi-virtualallocexnuma
"""
module Windows

using ..NumaAllocators: AbstractNumaAllocator
import ArrayAllocators: allocate, iszeroinit
using ArrayAllocators.ByteCalculators: nbytes
using ArrayAllocators.Windows: wrap_virtual, hCurrentProcess, MEM_COMMIT_RESERVE, PAGE_READWRITE, kernel32

function GetNumaProcessorNode(processor = GetCurrentProcessorNumber())
    node_number = Ref{Cuchar}(0)
    status = ccall((:GetNumaProcessorNode, kernel32), Cint, (Cuchar, Ptr{Cuchar}), processor, node_number)
    if status == 0
        error("Could not retrieve NUMA node for processor $processor.")
    end
    return node_number[]
end

# https://docs.microsoft.com/en-us/windows/win32/api/systemtopologyapi/nf-systemtopologyapi-getnumahighestnodenumber
function GetNumaHighestNodeNumber()
    node_number = Ref{Culong}(0)
    status = ccall((:GetNumaHighestNodeNumber, kernel32), Cint, (Ptr{Culong},), node_number)
    if status == 0
        error("Could not retrieve highest NUMA node.")
    end
    return node_number[]
end

function GetCurrentProcessorNumber()
    return ccall((:GetCurrentProcessorNumber, "kernel32"), Cint, ())
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

abstract type AbstractWinNumaAllocator{B} <: AbstractNumaAllocator{B} end

"""
    WinNumaAllocator

Allocate memory on a specific NUMA node with `VirtualAllocExNuma`.

See also https://docs.microsoft.com/en-us/windows/win32/api/memoryapi/nf-memoryapi-virtualallocexnuma
"""
struct WinNumaAllocator{B} <: AbstractWinNumaAllocator{B}
    node::Int
end

function allocate(n::WinNumaAllocator, num_bytes)
    return VirtualAllocExNuma(num_bytes, n.node)
end
Base.unsafe_wrap(::WinNumaAllocator, args...) = wrap_virtual(args...)
iszeroinit(::Type{A}) where A <: WinNumaAllocator = true

end # module Windows
