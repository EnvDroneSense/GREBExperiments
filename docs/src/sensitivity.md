# Climate sensitivity

[`gregory`](@ref) estimates how strongly the model responds to a forcing from one abrupt-forcing run, without waiting for equilibrium.

## The method

After the CO2 is raised at once, the top-of-atmosphere net flux ``N`` starts at the forcing ``F`` and falls toward zero as the surface warms by ``\Delta T``. To first order the two are linear:

```math
N = F + \lambda \, \Delta T
```

`gregory(dTs, dnet)` fits this line to annual global means of the surface-temperature change `dTs` [K] and the net-flux change `dnet` [W/m2] by least squares, and returns:

| Field | Meaning |
|:------|:--------|
| `forcing` | The fit at zero warming, ``F`` [W/m2] |
| `feedback` | The slope, ``\lambda`` [W/m2/K]; negative for a stable climate |
| `sensitivity` | ``-F / \lambda`` [K]: the warming at which the fit reaches zero net flux |
| `r2` | How well a straight line describes the run |
| `reached` | The last `dTs` of the run |
| `remaining` | The last `dnet` of the run |

It needs at least three annual values.

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

Use the `Ts` and `net` series of the scenario in the summary of an abrupt-CO2 preset, such as `:co2_double`:

```julia
using GREBClimate, GREBExperiments

fields = load_climatology(greb_data_dir(; allow_download=false); dataset=:ncep)
result = greb_model!(RunSpec(ctrl=5, scnr=100), preset(:co2_double; corrections=SpinUp(3));
    jld2_dir=greb_data_dir(; allow_download=false), fields=fields)
s = summarize(result)
g = gregory(s.scnr.Ts, s.scnr.net)
```

`scripts/sensitivity.jl` does this and prints the result; see [Running the scripts](@ref).

## What the number means

- The sensitivity is an effective one: it comes from the first decades of a run, not from equilibrium. The deep ocean has not yet warmed, so a longer run can give another value.
- It can differ from `reached`. The net flux here is `sw - olr`, which is not the whole energy budget of the scenario anomaly. `remaining` shows how much of the imbalance is left at the end.
- It is meaningful only for a preset whose scenario output is an anomaly (`scnr_anomaly` is `true`) and whose forcing is applied at once.
- A low `r2` means the response is not a straight line over the years used, for example because of sea ice or a changing forcing. Do not read the sensitivity then.
