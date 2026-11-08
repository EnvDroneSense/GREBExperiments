"""
    GREBExperiments

Helpers for experiments that run GREBClimate.jl and reduce its results: annual
and area-weighted means, the Gregory sensitivity estimate, map diagnostics.
Scripts that use them are in `experiments/`.
"""
module GREBExperiments

using GREBClimate

export annual_means, summarize, in_range_report, gregory, area_mean, zonal_mean, polar_amplification,
       land_ocean, pattern_correlation, sine_fit

include("helpers.jl")

end # module
