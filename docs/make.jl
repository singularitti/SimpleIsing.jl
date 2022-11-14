using SimpleIsing
using Documenter

DocMeta.setdocmeta!(SimpleIsing, :DocTestSetup, :(using SimpleIsing); recursive=true)

makedocs(;
    modules=[SimpleIsing],
    authors="singularitti <singularitti@outlook.com> and contributors",
    repo="https://github.com/singularitti/SimpleIsing.jl/blob/{commit}{path}#{line}",
    sitename="SimpleIsing.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://singularitti.github.io/SimpleIsing.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/singularitti/SimpleIsing.jl",
    devbranch="main",
)
