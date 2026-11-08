# =============================================================================
# docs/make.jl - builds the GREBExperiments Documenter site.
#
# Local build (once, to link the docs environment to the local source):
#   julia --project=docs -e 'using Pkg; Pkg.develop(path="."); Pkg.instantiate()'
#   julia --project=docs docs/make.jl
#
# CI (see .github/workflows/docs.yml) uses julia-actions/julia-docdeploy@v1,
# which runs the equivalent `Pkg.develop` step before this file.
# =============================================================================

using Documenter
using GREBExperiments

# makedocs runs the `jldoctest` blocks and fails the build on a mismatch.
DocMeta.setdocmeta!(GREBExperiments, :DocTestSetup, :(using GREBExperiments); recursive=true)

makedocs(
    sitename="GREBExperiments",
    modules=[GREBExperiments],
    authors="Thomas Struys",
    # Set explicitly: a clone without a GitHub remote (before the first push) cannot infer it.
    repo=Documenter.Remotes.GitHub("EnvDroneSense", "GREBExperiments"),
    format=Documenter.HTML(edit_link="main"),
    checkdocs=:exports,
    pages=[
        "Home" => "index.md",
        "Running the scripts" => "scripts.md",
        "Helpers" => [
            "Reducing a run" => "reducing.md",
            "Climate sensitivity" => "sensitivity.md",
            "Map diagnostics" => "maps.md",
            "Fitting a cycle" => "cycles.md"
        ],
        "API Reference" => "api.md"
    ]
)

deploydocs(
    repo="github.com/EnvDroneSense/GREBExperiments.git",
    devbranch="main"
)
