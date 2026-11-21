# Helpers for experiment scripts: reduce a `greb_model!` result to a few numbers
# and compute the usual diagnostics from maps and series. Pure functions; none
# runs the model. Every mean is area-weighted. `summarize` reads the result's
# `scnr_anomaly` to tell anomalies from absolute records.
#
#   using GREBExperiments: summarize, gregory

const G = GREBClimate

const WEIGHT = [Float64(G.dxlat_grid[j]) for _ in 1:G.xdim, j in 1:G.ydim]

"""
    area_mean(map, mask=nothing)

Area-weighted mean of a (`xdim`, `ydim`) map, over the cells where `mask` is
`true` when a mask is given. A mask of another type is used as a weight.
"""
function area_mean(map::AbstractMatrix, mask=nothing)
    size(map) == (G.xdim, G.ydim) || throw(DimensionMismatch("expected a ($(G.xdim), $(G.ydim)) map, got $(size(map))"))
    mask === nothing || size(mask) == (G.xdim, G.ydim) ||
        throw(DimensionMismatch("expected a ($(G.xdim), $(G.ydim)) mask, got $(size(mask))"))
    w = mask === nothing ? WEIGHT : WEIGHT .* mask
    sum(w) > 0 || throw(ArgumentError("the mask selects no cell"))
    return sum(Float64.(map) .* w) / sum(w)
end

"The mean over longitude of a map: one value per latitude row."
function zonal_mean(map::AbstractMatrix)
    size(map) == (G.xdim, G.ydim) || throw(DimensionMismatch("expected a ($(G.xdim), $(G.ydim)) map, got $(size(map))"))
    return vec(sum(Float64.(map); dims=1)) ./ G.xdim
end

"""
    polar_amplification(map; latitude=60)

`(north, south, north_mean, south_mean, global_mean)`: `north` and `south` are
the mean of `map` poleward of `latitude` degrees over its global mean, for each
hemisphere; the other three are the means themselves. A uniform map gives
`north = south = 1.0`. When the global mean is near zero (a regional or residual
map) the ratio is very large or changes sign: use the means then.
"""
function polar_amplification(map::AbstractMatrix; latitude::Real=60)
    lat = G.lat_grid
    rows(mask) = [mask[j] for _ in 1:G.xdim, j in 1:G.ydim]
    g = area_mean(map)
    n, s = area_mean(map, rows(lat .>= latitude)), area_mean(map, rows(lat .<= -latitude))
    return (north=n / g, south=s / g, north_mean=n, south_mean=s, global_mean=g)
end

"""
    land_ocean(map, z_topo)

`(land, ocean)`: the area-weighted means of `map` over the land and the ocean
cells, land being where the topography `z_topo` says so.
"""
function land_ocean(map::AbstractMatrix, z_topo::AbstractMatrix)
    land = G.is_land.(z_topo)
    return (land=area_mean(map, land), ocean=area_mean(map, .!land))
end

"""
Area-weighted correlation of two maps, about their own weighted means. A
constant map has no pattern: it throws an `ArgumentError`.
"""
function pattern_correlation(a::AbstractMatrix, b::AbstractMatrix)
    ma, mb = area_mean(a), area_mean(b)
    da, db = Float64.(a) .- ma, Float64.(b) .- mb
    va, vb = sum(WEIGHT .* da .^ 2), sum(WEIGHT .* db .^ 2)
    (va > 0 && vb > 0) || throw(ArgumentError("a constant map has no pattern to correlate"))
    return sum(WEIGHT .* da .* db) / sqrt(va * vb)
end

"""
    sine_fit(series, period)

Least-squares fit of `c + a sin(2 pi t / period) + b cos(2 pi t / period)` to
`series`, `t` in samples from 0. Returns `(amplitude, lag, mean)`: the
amplitude is `hypot(a, b)` and the lag is in samples, positive when the series
peaks later than `sin`. The lag is wrapped to (-period/2, period/2]: a true lag
of 0.6 periods comes back as -0.4 periods. There is no trend term, so cover a
whole number of periods; a series shorter than one period throws.
"""
function sine_fit(series::AbstractVector{<:Real}, period::Real)
    length(series) >= period || throw(ArgumentError("the series ($(length(series)) samples) is shorter than one period ($period)"))
    t = 0:(length(series)-1)
    ω = 2π / period
    design = hcat(ones(length(t)), sin.(ω .* t), cos.(ω .* t))
    c, a, b = design \ Float64.(series)
    # c + A sin(ω (t - lag)) = c + A cos(ω lag) sin(ωt) - A sin(ω lag) cos(ωt)
    lag = atan(-b, a) / ω
    return (amplitude=hypot(a, b), lag=lag, mean=c)
end

"""
    annual_means(records, times, f)

`(years, values, dropped)`: for each year with all 12 months among `records`,
the mean over the year of `f(record)`, where `f` is a field name (the
area-weighted mean of that field) or a function of a record that returns a
number. `dropped` lists the years with fewer than 12 months. `times` holds the
`(year, month)` of each record; a `(year, month)` that occurs twice, as in two
joined runs, throws an `ArgumentError`.

The months have equal weight. Give `month_weights` (12 values, for example the
days per month) to change that; the effect is zero for a constant and small for
an anomaly.
"""
function annual_means(records, times, f; month_weights::AbstractVector{<:Real}=ones(12))
    length(month_weights) == 12 || throw(ArgumentError("month_weights needs 12 values, got $(length(month_weights))"))
    length(records) == length(times) || throw(DimensionMismatch("$(length(records)) records, $(length(times)) times"))
    value(rec) = f isa Symbol ? global_mean(getproperty(rec, f)) : Float64(f(rec))
    sums = Dict{Int,Float64}()
    months = Dict{Int,Int}()
    seen = Set{Tuple{Int,Int}}()
    for (rec, t) in zip(records, times)
        (t.year, t.month) in seen && throw(ArgumentError("month $(t.month) of year $(t.year) occurs twice"))
        push!(seen, (t.year, t.month))
        sums[t.year] = get(sums, t.year, 0.0) + month_weights[t.month] * value(rec)
        months[t.year] = get(months, t.year, 0) + 1
    end
    years = sort!([y for (y, n) in months if n == 12])
    dropped = sort!([y for (y, n) in months if n < 12])
    return (years=years, values=[sums[y] / sum(month_weights) for y in years], dropped=dropped)
end

# Largest allowed size of a monthly anomaly per field [K, kg/kg]: above a strong
# forced change, below a diverged run
const ANOMALY_LIMITS = (Ts=80.0, Ta=80.0, To=40.0, q=0.08)

"""
    in_range_report(records, times, anomaly; anomaly_limits=ANOMALY_LIMITS)

`nothing` when every record is finite and inside the allowed range, otherwise
`(year, month, field, value)` of the first one that is not. For absolute
records the range is that of `GREBClimate.RangeCheck()` for `Ts`, `Ta`, `To`
and `q`. For anomalies the size of a value must not exceed the field's entry
in `anomaly_limits` (80 K for `Ts` and `Ta`, 40 K for `To`, 0.08 kg/kg for `q`).

The records are monthly means: a short excursion inside a month, or in a field
that is not tested, is not seen. For a member that can diverge, also pass
`GREBClimate.RangeCheck()` as the `observer` of `greb_model!`.
"""
function in_range_report(records, times, anomaly::Bool; anomaly_limits::NamedTuple=ANOMALY_LIMITS)
    limits = G.RangeCheck().limits
    for (rec, t) in zip(records, times), field in keys(limits)

        lower, upper = limits[field]
        for x in getproperty(rec, field)
            ok = anomaly ? isfinite(x) && abs(x) <= anomaly_limits[field] : lower <= x <= upper
            ok || return (year=t.year, month=t.month, field=field, value=x)
        end
    end
    return nothing
end

"""
    summarize(result)

Reduce a `greb_model!` result to a few kilobytes: for the control and the
scenario, the annual global means of `Ts`, `precip`, `ice` and the top-of-atmosphere
net (`sw - olr`), with their years (`ice` is the ice fraction, 0 to 1); whether
the scenario is an anomaly; `drift`, the change of the control's annual `Ts`
from its first to its last year [K] (`NaN` for one year; a control that is in
equilibrium has none); and
`out_of_range`, the first record outside the range (`nothing` when none; see
[`in_range_report`](@ref)). The control and the scenario are both tested, since a
scenario can leave the range while its control is fine.
"""
function summarize(result)
    series(records, times) = begin
        years, Ts = annual_means(records, times, :Ts)
        (; years, Ts,
            precip=annual_means(records, times, :precip)[2],
            ice=annual_means(records, times, :ice)[2],
            net=annual_means(records, times, rec -> global_mean(rec.sw) - global_mean(rec.olr))[2])
    end
    anomaly = get(result, :scnr_anomaly, false)
    ctrl = series(result.ctrl, result.ctrl_time)
    return (ctrl=ctrl,
        scnr=series(result.scnr, result.scnr_time),
        scnr_anomaly=anomaly,
        drift=length(ctrl.Ts) >= 2 ? ctrl.Ts[end] - ctrl.Ts[1] : NaN,
        out_of_range=(ctrl=in_range_report(result.ctrl, result.ctrl_time, false),
            scnr=in_range_report(result.scnr, result.scnr_time, anomaly)))
end

"""
    gregory(dTs, dnet)

Gregory estimate from annual global means of a surface-temperature change `dTs`
[K] and a top-of-atmosphere net-flux change `dnet` [W/m2], for example the
`Ts` and `net` series of the scenario in [`summarize`](@ref) of an abrupt-CO2
run. Fits `dnet = forcing + feedback * dTs`.

Returns `forcing` (W/m2), `feedback` (W/m2/K), `sensitivity` (K, the warming at
which the fit reaches zero net flux, `-forcing / feedback`), `r2`, `reached` (the
last `dTs`), `remaining` (the last `dnet`) and `closure` (`reached / sensitivity`).

The sensitivity can differ from `reached`, so `closure` can differ from 1 even
near equilibrium: `sw - olr` is not the whole budget of the anomaly. Two flows
outside it also change with the warming: the latent heat of the open water
budget (evaporation and rain do not balance) and the heat sink of the
transport. In an abrupt 2xCO2 run they make the sensitivity about 10 percent
lower than the warming the run reaches.

A constant `dTs` throws an `ArgumentError`. A `feedback >= 0` (no stable
equilibrium on the fitted line) gives `sensitivity` and `closure` as `NaN`, with
a warning.
"""
function gregory(dTs::AbstractVector{<:Real}, dnet::AbstractVector{<:Real})
    length(dTs) == length(dnet) >= 3 || throw(ArgumentError("need at least three annual values of each series"))
    x, y = Float64.(dTs), Float64.(dnet)
    mx, my = sum(x) / length(x), sum(y) / length(y)
    sxx = sum(abs2, x .- mx)
    sxx > 0 || throw(ArgumentError("dTs is constant: the slope is undefined"))
    feedback = sum((x .- mx) .* (y .- my)) / sxx
    forcing = my - feedback * mx
    residual = y .- (forcing .+ feedback .* x)
    r2 = 1 - sum(abs2, residual) / sum(abs2, y .- my)
    sensitivity = if feedback < 0
        -forcing / feedback
    else
        @warn "gregory: feedback is $feedback W/m2/K (not negative); the sensitivity is undefined"
        NaN
    end
    return (forcing=forcing, feedback=feedback, sensitivity=sensitivity, r2=r2,
        reached=x[end], remaining=y[end], closure=x[end] / sensitivity)
end
