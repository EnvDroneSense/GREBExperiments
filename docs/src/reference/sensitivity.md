# Sensitivity estimate

[`gregory`](@ref) estimates how strongly the model responds to a forcing. It uses one abrupt-forcing run and does not wait for equilibrium. The Guide page [Climate sensitivity](@ref) explains the method.

## The fit

`gregory(dTs, dnet)` fits the line ``N = F + \lambda \, \Delta T`` to the annual global means. The forcing ``F`` is the fit at zero warming, the feedback ``\lambda`` is the slope, and the sensitivity ``-F / \lambda`` is the warming at which the fit reaches zero net flux. The docstring of [`gregory`](@ref) lists all fields of the result.

```jldoctest
julia> using GREBExperiments

julia> dT = [0.5, 1.0, 1.5, 2.0];

julia> g = gregory(dT, 5.0 .- 2.0 .* dT);

julia> (g.forcing, g.feedback, g.sensitivity)
(5.0, -2.0, 2.5)

julia> (g.reached, g.remaining)
(2.0, 1.0)
```

## With a model run

Use the `Ts` and `net` series of the scenario in the [`summarize`](@ref) result of an abrupt-CO2 preset, such as `:co2_double`:

```julia
using GREBClimate, GREBExperiments

fields = load_climatology(greb_data_dir(; allow_download=false); dataset=:ncep)
result = greb_model!(RunSpec(ctrl=5, scnr=100), preset(:co2_double; corrections=SpinUp(3));
    jld2_dir=greb_data_dir(; allow_download=false), fields=fields)
s = summarize(result)
g = gregory(s.scnr.Ts, s.scnr.net)
```

`scripts/sensitivity.jl` does this and prints the result. See [Running the scripts](@ref).

## Limits of the estimate

- The sensitivity is an effective sensitivity. It comes from the first decades of a run, not from equilibrium. The deep ocean has not warmed yet, so a longer run can give a different value.
- It can differ from `reached`, because `sw - olr` is not the full energy budget of the anomaly. The docstring of [`gregory`](@ref) gives the two other flows. `closure` shows the ratio, and `remaining` shows how much of the imbalance stays at the end.
- It has a meaning only for a preset that gives its scenario as an anomaly (`scnr_anomaly` is `true`) and applies its forcing at one time.
- A low `r2` shows that the response is not a straight line over the years used, for example because of sea ice or a forcing that changes. Do not use the sensitivity then.
