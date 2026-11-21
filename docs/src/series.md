# Fitting a cycle

[`sine_fit`](@ref) fits one sine wave of a known period to a series. Use it for the response of the model to a periodic forcing, such as a CO2 or solar cycle. It tells how large the response is and how much it lags the forcing.

## The fit

The function fits, by least squares,

```math
c + a \sin(2\pi t / P) + b \cos(2\pi t / P)
```

with `t` counted in samples from 0 and the period ``P`` in samples. It returns the amplitude ``\sqrt{a^2 + b^2}``, the lag in samples and the mean ``c``.

```jldoctest
julia> using GREBExperiments

julia> period, lag = 40, 5.0;

julia> series = [2 + 3 * sin(2π * (t - lag) / period) for t in 0:159];

julia> fit = sine_fit(series, period);

julia> round.((fit.amplitude, fit.lag, fit.mean); digits = 6)
(3.0, 5.0, 2.0)
```

## Using it on a run

Get the annual global means of a run under a periodic forcing from [`annual_means`](@ref), and fit them with the period in years. Do this for several periods to get the amplitude and the lag of the response as a function of the period. This shows over which time scales the climate follows its forcing.

## Limits

- The period must be known. The series must hold at least one whole period, and a few periods give a better fit.
- Remove the spin-up from the series first. A drift that still decays looks like a long-period component and makes the fit worse.
- The function fits one frequency. A response with several frequencies, or one that changes with time, needs a different tool.
