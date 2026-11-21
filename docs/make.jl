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

# The changelog page is a copy of CHANGELOG.md, so the file stays the one source.
cp(joinpath(@__DIR__, "..", "CHANGELOG.md"), joinpath(@__DIR__, "src", "reference", "changelog.md"); force=true)

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
        "Guide" => [
            "Getting started" => "guide/start.md",
            "Experiments" => "guide/experiments.md",
            "Climate sensitivity" => "guide/sensitivity.md",
            "Climate patterns" => "guide/patterns.md"
        ],
        "Reference" => [
            "Running the scripts" => "reference/scripts.md",
            "Reducing a run" => "reference/reducing.md",
            "Sensitivity estimate" => "reference/sensitivity.md",
            "Map diagnostics" => "reference/maps.md",
            "Fitting a cycle" => "reference/series.md",
            "Experiment plots" => "reference/plots.md",
            "API Reference" => "reference/api.md",
            "Changelog" => "reference/changelog.md"
        ]
    ]
)

deploydocs(
    repo="github.com/EnvDroneSense/GREBExperiments.git",
    devbranch="main"
)
