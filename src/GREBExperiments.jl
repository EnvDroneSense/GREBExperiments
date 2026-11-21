"""
    GREBExperiments

Helpers for experiments that run GREBClimate.jl and reduce its results: annual
and area-weighted means, the Gregory sensitivity estimate, map diagnostics.
Scripts that use them are in `scripts/`.
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
