# Fitting a cycle

[`sine_fit`](@ref) fits one sine wave of a known period to a series. It is for the response of the model to a periodic forcing, such as a CO2 or solar cycle, where the questions are how large the response is and how far it lags the forcing.

## The fit

`sine_fit(series, period)` fits, by least squares,

```math
c + a \sin(2\pi t / P) + b \cos(2\pi t / P)
```

to `series`, with `t` counted in samples from 0 and the period ``P`` in samples. It returns:

| Field | Meaning |
|:------|:--------|
| `amplitude` | ``\sqrt{a^2 + b^2}``, in the unit of the series |
| `lag` | In samples; positive when the series peaks later than a sine that starts at 0 |
| `mean` | The constant ``c`` |

```jldoctest
julia> using GREBExperiments

julia> period, lag = 40, 5.0;

julia> series = [2 + 3 * sin(2π * (t - lag) / period) for t in 0:159];

julia> fit = sine_fit(series, period);

julia> round.((fit.amplitude, fit.lag, fit.mean); digits = 6)
(3.0, 5.0, 2.0)
```

## Using it on a run

Take the annual global means from [`annual_means`](@ref) of a run under a periodic forcing, with the period in years, and fit them. Repeating this for several periods gives the amplitude and the lag of the response as a function of period, which shows over which time scales the climate follows its forcing.

## Limits

- The period must be known and the series should hold at least a few whole periods; a fit to less than one period is not meaningful.
- Remove the spin-up from the series first. A drift that is still decaying looks like a long-period component and lowers the fit.
- It fits one frequency. A response with several, or one that changes over time, needs a different tool.
