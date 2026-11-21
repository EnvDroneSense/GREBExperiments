# Set up the notebook environment: link it to the local clones of this package and
# of GREBClimate (neither is registered), then install Plots, Pluto and PlutoUI.
# Run it again after updating either clone.
#
#   julia notebooks/setup.jl
#   julia --project=notebooks -e 'using Pluto; Pluto.run(notebook="notebooks/climate_experiments.jl")'

using Pkg
Pkg.activate(@__DIR__)
Pkg.develop(path=joinpath(@__DIR__, ".."))
Pkg.develop(path=joinpath(@__DIR__, "..", "..", "GREB-julia"))
Pkg.instantiate()
