# Reducing a run

A `greb_model!` run returns one record per month for the control and for the scenario. Each record is a set of 96 x 48 maps, so an ensemble of long runs does not fit in memory. Thus the first task of an experiment script is to reduce each run to a few numbers. These three functions do that.

| Function | Input | Output |
|:---------|:------|:-------|
| [`annual_means`](@ref) | Records, their times, a field name or a function | The complete years and the annual global mean of that field |
| [`summarize`](@ref) | A `greb_model!` result | Annual global means of `Ts`, `precip`, `ice` and the net flux, for control and scenario |
| [`in_range_report`](@ref) | Records, their times, whether they are anomalies | `nothing`, or the first record outside the allowed range |

## Annual means

[`annual_means`](@ref) groups the records by calendar year and averages the global mean of each record. A record is any value that has the fields that the function reads. This example has two years of records of a uniform surface temperature, with one value per month:

```jldoctest
julia> using GREBExperiments, GREBClimate

julia> record(v) = (Ts = fill(Float32(v), xdim, ydim),);

julia> times = [(year = 1950 + (i - 1) ÷ 12, month = mod1(i, 12)) for i in 1:24];

julia> years, values, dropped = annual_means([record(m) for m in 1:24], times, :Ts);

julia> years
2-element Vector{Int64}:
 1950
 1951

julia> values
2-element Vector{Float64}:
  6.5
 18.5

julia> dropped
Int64[]
```

The mean of the months 1 to 12 is 6.5, and the mean of the months 13 to 24 is 18.5. A function in place of the field name gives the mean of a derived quantity. An example is the top-of-atmosphere net flux `rec -> global_mean(rec.sw) - global_mean(rec.olr)`.

## The summary of a result

[`summarize`](@ref) applies `annual_means` to the fields that most experiments use, for the control and for the scenario. The result is a few kilobytes. Keep the summary and discard the result, so the memory is free for the next member of a sweep. The [Climate sensitivity](@ref) page shows how to use `Ts` and `net`.

## Checking that a run stayed in range

A model run that diverges does not stop with an error. It gives large or non-finite numbers. [`in_range_report`](@ref) finds the first record that is out of range:

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

Before a sweep averages its members, it must remove or flag each member whose `out_of_range` is not `(nothing, nothing)`.
