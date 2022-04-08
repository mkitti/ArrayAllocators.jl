module ByteCalculators

export nbytes, elsize
export UnsafeByteCalculator, CheckedMulByteCalculator, WideningByteCalculator

"""
    AbstractByteCalculator

Parent abstract type for byte calculators, which calculate the total number of bytes of memory to allocate.
"""
abstract type AbstractByteCalculator{T} end

# Allow dimensions to be passed an individual arguments
function (::Type{B})(dims::Int...) where {T, B <: AbstractByteCalculator{T}}
    return B(dims)
end
elsize(::AbstractByteCalculator{T}) where T = sizeof(T)
nbytes(b::AbstractByteCalculator{T}) where T = elsize(b) * length(b)

"""
    UnsafeByteCalculator

Calculate number of bytes to allocate for an array without any integer overflow checking.
"""
struct UnsafeByteCalculator{T} <: AbstractByteCalculator{T}
    dims::Dims
    UnsafeByteCalculator{T}(dims::Dims) where T = new{T}(dims)
end
Base.length(b::UnsafeByteCalculator{T}) where T = prod(b.dims)

"""
    CheckedMulByteCalculator

Calculate the number of bytes by using `Base.checked_mul` to check if the product of the dimensions (length)
or the product of the length and the element size will cause an integer overflow.
"""
struct CheckedMulByteCalculator{T} <: AbstractByteCalculator{T}
    dims::Dims
    CheckedMulByteCalculator{T}(dims::Dims) where T = new{T}(dims)
end
function Base.length(b::CheckedMulByteCalculator)
    try
        return reduce(Base.checked_mul, b.dims)
    catch err
        if err isa OverflowError
            rethrow(OverflowError("The product of the dimensions results in integer overflow."))
        else
            rethrow(err)
        end
    end
end
function nbytes(b::CheckedMulByteCalculator{T}) where T
    element_size = sizeof(T)
    len = length(b)
    if len > typemax(typeof(element_size)) ÷ element_size
        throw(OverflowError("The product of array length and element size will cause an overflow."))
    end
    return element_size * len
end

"""
    WideningByteCalculator

Widens `eltype(Dims)`, Int in order to catch integer overflow.
"""
struct WideningByteCalculator{T} <: AbstractByteCalculator{T}
    dims::Dims
    WideningByteCalculator{T}(dims::Dims) where T = new{T}(dims)
end

function Base.length(bc::WideningByteCalculator)
    D = eltype(Dims)
    M = typemax(D)
    W = widen(D)

    len = reduce(bc.dims) do a,b
        c = W(a) * W(b)
        if c > M
            throw(OverflowError("The product of the dimensions results in integer overflow."))
        end
        return D(c)
    end

    return len
end
function nbytes(b::WideningByteCalculator{T}) where T
    nb = widen(sizeof(T)) * widen(length(b))
    if nb > typemax(eltype(Dims))
        throw(OverflowError("The product of array length and element size will cause an overflow."))
    end
    return nb
end


end # module ByteCalculators
