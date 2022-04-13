# ByteCalculators

Byte calculators perform the task of computing the total number of bytes to calculate. In doing so, they try to detect integer overflow conditions.

## Example

```julia
julia> using ArrayAllocators, ArrayAllocators.ByteCalculators

julia> bc = ArrayAllocators.DefaultByteCalculator{UInt16}(typemax(Int))
CheckedMulByteCalculator{UInt16}((9223372036854775807,))

julia> length(bc)
9223372036854775807

julia> nbytes(bc)
ERROR: OverflowError: The product of array length and element size will cause an overflow.
Stacktrace:
[...]
```

```@index
```

```@autodocs
Modules = [ArrayAllocators.ByteCalculators, SafeByteCalculators]
```