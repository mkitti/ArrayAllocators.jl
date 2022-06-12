
# Compositions with other packages

## Compositions that are tested

### OffsetArrays.jl

[OffsetArrays.jl](https://github.com/JuliaArrays/OffsetArrays.jl) allows for the use of shifted indices. Composition is enabled by
1. `OffsetArrays` implements `Base.unsafe_wrap`
2. `AbstractByteCalculators` accept `AbstractUnitRange` arguments

```jldoctest
julia> using ArrayAllocators, OffsetArrays

julia> OffsetArray{Int}(calloc, -5:5, Base.OneTo(3))
11×3 OffsetArray(::Matrix{Int64}, -5:5, 1:3) with eltype Int64 with indices -5:5×1:3:
 0  0  0
 0  0  0
 0  0  0
 0  0  0
 0  0  0
 0  0  0
 0  0  0
 0  0  0
 0  0  0
 0  0  0
 0  0  0

julia> OffsetArray{Int}(calloc, 2, 3)
2×3 OffsetArray(::Matrix{Int64}, 1:2, 1:3) with eltype Int64 with indices 1:2×1:3:
 0  0  0
 0  0  0
```

## Adding to the list of known compositions

Does your package compose well with ArrayAllocators or its subpackages?

If so, please let me know by [creating an issue](https://github.com/mkitti/ArrayAllocators.jl/issues/new).

It is important to list known compositions so users know which packages are known to work well together.
Additionally, this helps to make sure that packages continue to compose over time. Beyond listing the
known composition, I will also add additional tests for them.
