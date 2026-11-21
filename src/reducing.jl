# Reduce a `greb_model!` result to a few numbers and check that it stayed in range.

export in_range_report, summarize

# Largest allowed size of a monthly anomaly per field [K, kg/kg]. Each limit is
# far above a strong forced change and far below a diverged run.
const ANOMALY_LIMITS = (Ts=80.0, Ta=80.0, To=40.0, q=0.08)

"""
    in_range_report(records, times, anomaly; anomaly_limits=ANOMALY_LIMITS)

Return `nothing` when all values of `Ts`, `Ta`, `To` and `q` in `records` are
finite and in the allowed range. Otherwise return `(year, month, field, value)`
of the first value that is not. `times` holds the `(year, month)` of each record.

For absolute records (`anomaly=false`), the range is that of
`GREBClimate.RangeCheck()`. For anomalies, the size of a value must not exceed
the entry of its field in `anomaly_limits`: by default 80 K for `Ts` and `Ta`,
40 K for `To` and 0.08 kg/kg for `q`.

The records are monthly means, so the function does not see a short excursion
inside a month or a value in a different field. For a member that can diverge,
also give `GREBClimate.RangeCheck()` as the `observer` of `greb_model!`.
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

Reduce a `greb_model!` result to a few kilobytes and return a `NamedTuple`:

| Field | Content |
|:------|:--------|
| `ctrl`, `scnr` | `(years, Ts, precip, ice, net)`: the complete years and the annual global means. `ice` is the ice fraction (0 to 1). `net` is the top-of-atmosphere net flux `sw - olr` |
| `scnr_anomaly` | `true` when the scenario records are anomalies from the control |
| `drift` | The change of the annual `Ts` of the control from its first to its last year [K]; `NaN` for one year. A control in equilibrium has no drift |
| `out_of_range` | `(ctrl, scnr)`: for each phase, `nothing` or the first record out of range (see [`in_range_report`](@ref)) |

The function tests the control and the scenario separately, because a scenario
can leave the range while its control stays in range.
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
