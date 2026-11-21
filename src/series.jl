# Numbers from series: annual means, a fitted cycle and the Gregory estimate.

export annual_means, sine_fit, gregory

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
