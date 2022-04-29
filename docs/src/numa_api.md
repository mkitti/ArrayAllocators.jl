```@meta
CurrentModule = NumaAllocators
```

# Application Programming Interface for NumaAllocators.jl

```@docs
NumaAllocators
```

## Main Interface

```@docs
numa
NumaAllocator
current_numa_node
highest_numa_node
```

## Platform Specific Interface

### Windows

```@docs
NumaAllocators.Windows
NumaAllocators.Windows.WinNumaAllocator
```

### Linux

```@docs
NumaAllocators.LibNUMA
NumaAllocators.LibNUMA.LibNumaAllocator
```
