using Documenter
using Preliz

makedocs(
    sitename="Preliz",
    format=Documenter.HTML(sidebar_sitename=false),
    pages=[],
    modules=[Preliz]
)

deploydocs(
    repo="github.com/samanklesaria/Preliz.jl.git",
    devbranch="main"
)
