"""
    SafeByteCalculators

Extension of [`ArrayAllocators.ByteCalculators`](@ref) using [SaferIntegers.jl](https://github.com/JeffreySarnoff/SaferIntegers.jl).
"""
module SafeByteCalculators

import ArrayAllocators
using ArrayAllocators.ByteCalculators: AbstractByteCalculator
using SaferIntegers: SafeInt

export SafeByteCalculator

"""
    SafeByteCalculator

Use `SafeInt` from SaferIntegers.jl to calculate the number of bytes to allocate for an Array.
"""
struct SafeByteCalculator{T} <: AbstractByteCalculator{T}
    dims::Dims
    SafeByteCalculator{T}(dims::Dims) where T = new{T}(dims)
end
Base.length(b::SafeByteCalculator) = prod(SafeInt.(b.dims))

end # module SafeByteCalculator
