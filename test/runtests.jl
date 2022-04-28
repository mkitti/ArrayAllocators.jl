using Pkg
using ArrayAllocators
using ArrayAllocators.ByteCalculators
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
    @test A == B
    @test size(M) == (1024, 4096)
    
    @test_throws OverflowError Array{UInt8}(calloc, 20480000, typemax(Int64))
    @test_throws OverflowError Array{UInt16}(calloc, 2, typemax(Int64)÷2)

    @test_throws OverflowError Array{UInt16}(MallocAllocator(), 2, typemax(Int64)÷2)
    @test_throws OverflowError Array{UInt16}(MallocAllocator{CheckedMulByteCalculator}(), 2, typemax(Int64)÷2)
    @test_throws OverflowError Array{UInt16}(MallocAllocator{WideningByteCalculator}(), 2, typemax(Int64)÷2)
    @test_throws OverflowError Array{UInt16}(MallocAllocator{SafeByteCalculator}(), 2, typemax(Int64)÷2)

    if isdefined(ArrayAllocators, :Windows)
        WV = Array{UInt8}(ArrayAllocators.Windows.virtual, 64, 1024);
        @test size(WV) == (64, 1024)
        @test WV == zeros(UInt8, 64, 1024)
    end
    if isdefined(NumaAllocators, :NumaAllocator)
        C = Array{UInt8}(NumaAllocator(0), 2048, 2048);
        @test A == C
    end

    if isdefined(ArrayAllocators, :MemAlign)
        memalign = MemAlign()
        D = Array{UInt8}(memalign, 1024, 4096)
        @test size(D) == (1024, 4096)
        @test reinterpret(Int, pointer(D)) % ArrayAllocators.alignment(memalign) == 0
    end

end
