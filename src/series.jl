# Numbers from series: annual means, a fitted cycle and the Gregory estimate.

export annual_means, sine_fit, gregory

"""
    sine_fit(series, period)

Fit `c + a sin(2 pi t / period) + b cos(2 pi t / period)` to `series` by least
squares, with `t` in samples from 0. Return `(amplitude, lag, mean)`:

| Field | Content |
|:------|:--------|
| `amplitude` | `hypot(a, b)`, in the unit of the series |
| `lag` | In samples; positive when the series peaks later than `sin`. It is wrapped to (-period/2, period/2]: a true lag of 0.6 periods gives -0.4 periods |
| `mean` | `c` |

The fit has no trend term, so give a whole number of periods. A series shorter
than one period throws an `ArgumentError`.
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

Return `(years, values, dropped)`. For each year that has all 12 months in
`records`, `values` holds the annual mean of `f(record)`. `dropped` lists the
years with fewer than 12 months, so a partial year does not look like a full one.

`f` is a field name, such as `:Ts`, for the area-weighted global mean of that
field. It can also be a function of one record that returns a number. `times`
holds the `(year, month)` of each record. A `(year, month)` that occurs twice,
as in two joined runs, throws an `ArgumentError`.

All months have the same weight. To change this, give `month_weights` (12
values, for example the days per month). This has no effect on a constant and a
small effect on an anomaly.
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

"""
    gregory(dTs, dnet)

Fit `dnet = forcing + feedback * dTs` by least squares and return the Gregory
estimate. `dTs` [K] and `dnet` [W/m2] are annual global means of the change in
surface temperature and in top-of-atmosphere net flux. An example is the `Ts`
and `net` series of the scenario in [`summarize`](@ref) of an abrupt-CO2 run.

| Field | Content |
|:------|:--------|
| `forcing` | The fit at zero warming [W/m2] |
| `feedback` | The slope of the fit [W/m2/K]; negative for a stable climate |
| `sensitivity` | `-forcing / feedback` [K]: the warming at which the fit reaches zero net flux |
| `r2` | The coefficient of determination of the fit |
| `reached`, `remaining` | The last `dTs` and the last `dnet` |
| `closure` | `reached / sensitivity` |

`closure` can differ from 1 even near equilibrium, because `sw - olr` is not the
full budget of the anomaly. Two more flows change with the warming: the latent
heat of the open water budget (evaporation and rain do not balance) and the heat
sink of the transport. In an abrupt 2xCO2 run, they make the sensitivity
approximately 10 percent lower than the warming that the run reaches.

Each series needs at least three values. A constant `dTs` throws an
`ArgumentError`. When `feedback >= 0`, the fitted line has no stable
equilibrium: `sensitivity` and `closure` are `NaN`, and the function logs a
warning.
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
