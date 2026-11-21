# Reduce a `greb_model!` result to a few numbers and check that it stayed in range.
# `summarize` reads the result's `scnr_anomaly` to tell anomalies from absolute records.

export in_range_report, summarize

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
