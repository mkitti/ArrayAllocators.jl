using Pkg
using ArrayAllocators
using ArrayAllocators.ByteCalculators
using OffsetArrays
using Test

# Load in subpackages
Pkg.develop(PackageSpec(path=joinpath(dirname(@__DIR__), "./NumaAllocators")))
Pkg.develop(PackageSpec(path=joinpath(dirname(@__DIR__), "./SafeByteCalculators")))

using NumaAllocators
using SafeByteCalculators

@testset "ArrayAllocators.jl" begin
    A = zeros(UInt8, 2048, 2048);
    B = Array{UInt8}(calloc, 2048, 2048);
    M = Array{UInt8}(malloc, 1024, 4096)
    Z = ArrayAllocators.zeros(UInt8, 2048, 2048)
    Z2 = ArrayAllocators.zeros(UInt8, (2048, 2048))
    @test A == B
    @test A == Z
    @test size(Z) == (2048, 2048)
    @test size(Z2) == (2048, 2048)
    @test size(M) == (1024, 4096)
    
    @test_throws OverflowError Array{UInt8}(calloc, 20480000, typemax(Int64))
    @test_throws OverflowError Array{UInt16}(calloc, 2, typemax(Int64)÷2)

    @test_throws OverflowError Array{UInt16}(MallocAllocator(), 2, typemax(Int64)÷2)
    @test_throws OverflowError Array{UInt16}(MallocAllocator{CheckedMulByteCalculator}(), 2, typemax(Int64)÷2)
    @test_throws OverflowError Array{UInt16}(MallocAllocator{WideningByteCalculator}(), 2, typemax(Int64)÷2)
    @test_throws OverflowError Array{UInt16}(MallocAllocator{SafeByteCalculator}(), 2, typemax(Int64)÷2)

    @static if Sys.iswindows()
        WV = Array{UInt8}(ArrayAllocators.Windows.virtual, 64, 1024);
        @test size(WV) == (64, 1024)
        @test WV == zeros(UInt8, 64, 1024)
    end
    @static if Sys.islinux() || Sys.iswindows()
        C = Array{UInt8}(NumaAllocator(0), 2048, 2048);
        @test A == C
        @test current_numa_node() isa Int
        @test highest_numa_node() isa Int
    end

    @static if Sys.isunix() || Sys.iswindows()
        D = Array{UInt8}(MemAlign(), 1024, 4096)
        @test size(D) == (1024, 4096)
        @test reinterpret(Int, pointer(D)) % ArrayAllocators.alignment(MemAlign()) == 0
        E = Array{UInt8}(MemAlign(2^16), 1024, 2048)
        @test size(E) == (1024, 2048)
        @test reinterpret(Int, pointer(E)) % 2^16 == 0
    end
end

@testset "Composition with OffsetArrays.jl" begin
    OA = OffsetArray{UInt8}(calloc, -1024:1023, -5:5)
    @test all(OA .== 0)
    @test size(OA) == (2048,11)
    @test OA[-1024,-3] == 0
    OA = OffsetArray{UInt8}(calloc, -5:3, Base.OneTo(9))
    @test all(OA .== 0)
    @test size(OA) == (9,9)
    @test OA[-1,5] == 0
    @static if Sys.islinux() || Sys.iswindows()
        numaOA = OffsetArray{UInt8}(numa(0), -5:5, 1:9)
        @test numaOA[-5, 1] == numaOA[1]
    end
end

# Add coverage testing