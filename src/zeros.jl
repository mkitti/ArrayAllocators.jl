"""
    ArrayAllocators.zeros(T=Float64, dims::Integer...)
    ArrayAllocators.zeros(T=Float64, dims::Dims)

Return an Array with element type `T` with size `dims` filled by `0`s via
`calloc`. Depending on the libc implementation, the operating system may lazily
wait for a page fault before obtaining memory initialized to `0`.
This is an alternative to `Base.zeros` that always fills the array with `0`
eagerly. 

# Examples
```julia
julia> @time ArrayAllocators.zeros(Int, 3200, 3200);
  0.000026 seconds (4 allocations: 78.125 MiB)

julia> @time Base.zeros(Int, 3200, 3200);
  0.133595 seconds (2 allocations: 78.125 MiB, 67.36% gc time)
 
julia> ArrayAllocators.zeros(Int, 256, 256) == Base.zeros(Int, 256, 256)
true
```
"""
function zeros(::Type{T}, dims::Integer...) where T
    return Array{T}(calloc, dims...)
end
function zeros(::Type{T}, dims::Dims) where T
    return Array{T}(calloc, dims)
end
zeros(dims::Integer...) = zeros(Float64, dims)
zeros(dims::Dims) = zeros(Float64, dims)

