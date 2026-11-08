# Fixtures for the tests: a small climate on the model grid, so the tests run
# without the dataset. Copied from the GREBClimate.jl test support; keep them
# in step by hand when the package changes.
using GREBClimate
using GREBClimate: lat_grid, is_land, MonthlyRecord
using Logging: with_logger, NullLogger

const X, Y, N = xdim, ydim, nstep_yr

"""Run `f` with the logger muted - the model logs a progress line per year."""
quiet(f) = with_logger(f, NullLogger())

gmean(x) = sum(x) / length(x)

"""
A `ClimateFields` non-degenerate enough to run the model without the real
dataset: finite mixed-layer depth, land in the western half, and non-zero
winds and humidity.
"""
function synthetic_fields()
    f = ClimateFields()
    f.mld_clim .= 50.0f0
    f.z_topo[1:(X-48), :] .= 100.0f0
    for k in 1:N, j in 1:Y, i in 1:X
        f.Ts_clim[i, j, k] = 288.0f0 - 40.0f0 * abs(j - Y / 2) / (Y / 2)
        f.u_clim[i, j, k] = 5.0f0 * sinpi(2 * j / Y)
        f.v_clim[i, j, k] = 2.0f0 * cospi(2 * i / X)
        f.q_clim[i, j, k] = 0.005f0
        f.wind_speed_clim[i, j, k] = 6.0f0
    end
    f.To_clim .= 283.0f0
    f.cloud_clim .= 0.5f0
    f.soil_wetness_clim .= 0.4f0
    GREBClimate.split_winds!(f)
    return f
end

"A `MonthlyRecord` with every field filled with `v`; a keyword sets one field to another value."
uniform_record(v; kw...) = MonthlyRecord(map(n -> fill(Float32(get(kw, n, v)), X, Y), fieldnames(MonthlyRecord)))

"The times of `n` monthly records from January of `start`."
record_times(start, n) = [(year=start + (i - 1) ÷ 12, month=mod1(i, 12)) for i in 1:n]

"""
Run `greb_model!(run, config)` with the logger muted, on `fields` (default
`synthetic_fields()`) and without the dataset.
"""
function run_synthetic(run, config; fields=synthetic_fields(), jld2_dir="", kwargs...)
    return quiet() do
        greb_model!(run, config; jld2_dir, fields, allow_uninitialized=true, kwargs...)
    end
end
