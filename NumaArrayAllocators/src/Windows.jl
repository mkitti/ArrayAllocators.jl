module Windows

using ..NumaArrayAllocators: AbstractNumaAllocator
import ArrayAllocators: DefaultByteCalculator, allocate
using ArrayAllocators.ByteCalculators: nbytes
using ArrayAllocators.Windows: wrap_virtual, hCurrentProcess, MEM_COMMIT_RESERVE, PAGE_READWRITE, kernel32

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

struct WinNumaAllocator{B} <: AbstractWinNumaAllocator{B}
    node::Int
end
WinNumaAllocator(node) = WinNumaAllocator{DefaultByteCalculator}(node)

function allocate(n::WinNumaAllocator, num_bytes)
    return VirtualAllocExNuma(num_bytes, n.node)
end
Base.unsafe_wrap(::WinNumaAllocator, args...) = wrap_virtual(args...)

end # module Windows
