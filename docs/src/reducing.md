# Reducing a run

A `greb_model!` run returns one record per month for the control and for the scenario: a set of 96 x 48 maps each. A year of records is about 12 maps of every output field, so an ensemble of long runs does not fit in memory. The first job of an experiment script is to reduce each run to a few numbers. These three functions do that.

| Function | Input | Output |
|:---------|:------|:-------|
| [`annual_means`](@ref) | Records, their times, a field name or a function | The complete years and the annual global mean of that field |
| [`summarize`](@ref) | A `greb_model!` result | Annual global means of `Ts`, `precip`, `ice` and the net flux, for control and scenario |
| [`in_range_report`](@ref) | Records, their times, whether they are anomalies | `nothing`, or the first record outside the allowed range |

## Annual means

`annual_means(records, times, f)` groups the records by calendar year and averages the global mean of each. A year counts only when all 12 months are present, so a run that ends in June does not return a half-year value that looks like a full one. `f` is a field name, such as `:Ts`, or a function of one record that returns a number.

Records are anything that has the fields asked for. Here two years of records of a uniform surface temperature, one value per month:

```jldoctest
julia> using GREBExperiments, GREBClimate

julia> record(v) = (Ts = fill(Float32(v), xdim, ydim),);

julia> times = [(year = 1950 + (i - 1) ÷ 12, month = mod1(i, 12)) for i in 1:24];

julia> years, values = annual_means([record(m) for m in 1:24], times, :Ts);

julia> years
2-element Vector{Int64}:
 1950
 1951

julia> values
2-element Vector{Float64}:
  6.5
 18.5
```

The mean of the months 1 to 12 is 6.5 and of 13 to 24 is 18.5. Every mean is area-weighted: a cell near the pole counts less than a cell on the equator. With a function, a derived quantity can be averaged, for example the net top-of-atmosphere flux `rec -> global_mean(rec.sw) - global_mean(rec.olr)`.

## The summary of a result

`summarize(result)` applies `annual_means` to the fields most experiments use and returns them for both phases:

| Field | Content |
|:------|:--------|
| `ctrl`, `scnr` | Each a named tuple with `years`, `Ts`, `precip`, `ice` and `net` (`sw - olr`) |
| `scnr_anomaly` | Whether the scenario records are anomalies from the control rather than absolute values |
| `out_of_range` | `(ctrl, scnr)`, each `nothing` or the first record outside the allowed range |

The result is a few kilobytes. Keep it, drop the result, and the memory is free for the next member of a sweep. The [Climate sensitivity](@ref) page shows what to do with `Ts` and `net`.

## Checking that a run stayed in range

A model run that diverges does not fail; it produces large or non-finite numbers. `in_range_report(records, times, anomaly)` returns `nothing` when every value is finite and inside the allowed range, and otherwise the year, month, field and value of the first record that is not. The range is the one of `GREBClimate.RangeCheck()` for `Ts`, `Ta`, `To` and `q`. For anomalies the bound is the width of that range, since an anomaly can be negative.

```jldoctest
julia> using GREBExperiments, GREBClimate

julia> record(T) = (Ts = fill(T, xdim, ydim), Ta = fill(250f0, xdim, ydim),
                    To = fill(280f0, xdim, ydim), q = fill(0.005f0, xdim, ydim));

julia> times = [(year = 1950, month = m) for m in 1:2];

julia> in_range_report([record(288f0)], times[1:1], false) === nothing
true

julia> in_range_report([record(288f0), record(1f24)], times, false)
(year = 1950, month = 2, field = :Ts, value = 1.0f24)
```

`summarize` tests the control and the scenario separately, because a scenario can leave the range while its control is fine. A sweep should drop or flag every member whose `out_of_range` is not `(nothing, nothing)` before it averages anything.
