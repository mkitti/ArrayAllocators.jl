using ArrayAllocators
using SafeByteCalculators
using NumaAllocators
using Documenter

DocMeta.setdocmeta!(ArrayAllocators, :DocTestSetup, :(using ArrayAllocators); recursive=true)

makedocs(;
    modules=[ArrayAllocators, SafeByteCalculators, NumaAllocators],
    authors="Mark Kittisopikul <kittisopikulm@janelia.hhmi.org> and contributors",
    repo="https://github.com/mkitti/ArrayAllocators.jl/blob/{commit}{path}#{line}",
    sitename="ArrayAllocators.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://mkitti.github.io/ArrayAllocators.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Detailed Overview" => "detailed_overview.md",
        "Byte Calculators" => "bytecalculators.md",
        "NUMA Array Allocators" => "numa.md"
    ],
)

deploydocs(;
    repo="github.com/mkitti/ArrayAllocators.jl",
    devbranch="main",
    push_preview = true
)
