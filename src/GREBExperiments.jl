"""
    GREBExperiments

Tools for experiments with GREBClimate.jl. The package runs sets of model
members, reduces each result to a few numbers (annual and area-weighted means,
the Gregory sensitivity estimate, map diagnostics) and writes the rows to files.
The scripts in `scripts/` use these tools.
"""
module GREBExperiments

using GREBClimate
using Dates: Dates
using TOML: TOML

include("common.jl")
include("maps.jl")
include("series.jl")
include("reducing.jl")
include("io.jl")
include("driver.jl")
include("plots.jl")

end # module
