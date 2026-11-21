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

export annual_means, summarize, in_range_report, gregory, area_mean, zonal_mean, polar_amplification,
       land_ocean, pattern_correlation, sine_fit, co2_file, run_members

include("helpers.jl")
include("co2file.jl")
include("driver.jl")

end # module
