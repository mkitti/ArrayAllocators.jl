using ArrayAllocators
using Documenter

DocMeta.setdocmeta!(ArrayAllocators, :DocTestSetup, :(using ArrayAllocators); recursive=true)

makedocs(;
    modules=[ArrayAllocators],
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
    ],
)

deploydocs(;
    repo="github.com/mkitti/ArrayAllocators.jl",
    devbranch="main",
)
