```@meta
CurrentModule = ArrayAllocators
```

# Application Programming Interface for ArrayAllocators.jl

```@docs
ArrayAllocators
```

## Allocators

```@docs
calloc
malloc
```

## Aligned Memory

```@docs
MemAlign
alignment
min_alignment
```

## Types

```@docs
CallocAllocator
MallocAllocator
UndefAllocator
```

## Internals

```@docs
AbstractArrayAllocator
AbstractMemAlign
DefaultByteCalculator
wrap_libc_pointer
lineage_finalizer
```

## Platform Specific Interface

### Windows

```@docs
ArrayAllocators.Windows
Windows.WinMemAlign
Windows.MemAddressRequirements
Windows.MemExtendedParameterAddressRequirements
```

### POSIX

```@docs
ArrayAllocators.POSIX
POSIX.PosixMemAlign
```

## Convenience

```@docs
ArrayAllocators.zeros
```
