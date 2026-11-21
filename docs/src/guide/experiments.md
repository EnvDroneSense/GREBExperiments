# Experiments

Each experiment changes one thing in the model, for example the CO2 level or the energy from the sun. The model first runs a control: a year with no change, at 340 ppm CO2 unless the table gives a different value. It then runs the scenario with the change. The difference between the two is the response of the model climate.

The notebook lists all experiments of GREBClimate. The [preset list](https://EnvDroneSense.github.io/GREBClimate.jl/stable/configuration/#Presets) of GREBClimate gives the exact settings. This page puts them in groups and tells what each group asks.

## Groups of experiments

| Group | Experiments | Question | What to look at |
|:------|:------------|:---------|:----------------|
| Constant CO2 | `co2_double` (680 ppm), `co2_quadruple` (1360), `co2_10x` (3400), `co2_half` (170), `co2_zero` | How much does the climate warm or cool after a sudden change of CO2? | The Gregory plot and the effective sensitivity. Compare `co2_double` and `co2_quadruple`: is the warming two times larger? |
| CO2 steps and cycles | `co2_abrupt_reverse`, `co2_sine_wave` | Does the climate go back when CO2 goes back? How fast does it follow a CO2 cycle? | The time series: the delay between the forcing and the temperature |
| Sun | `solar_plus27`, `solar_cycle_11yr` | Does a change of the sun give the same warming as CO2 at the same forcing? | The map: where it warms, compared with `co2_double` |
| Emission scenarios | `rcp26` to `rcp85`, `ssp119` to `ssp585`, `a1b`, `historical_co2` | How warm does the model get for each CO2 path? The control is at 280 ppm. The runs start in 1950 (`historical_co2` in 1850), The notebook allows 60 scenario years, so it does not reach the 21st century. | The time series of the global mean |
| Regional CO2 | `regional_co2_nh`, `_sh`, `_tropics`, `_extratropics`, `_ocean`, `_land_ice`, `_winter`, `_summer` | Does the warming stay where the CO2 increases? | The map: the warming inside and outside the region |
| Ocean surface | `sst_plus1`, `elnino`, `lanina`, `rcp85_boundary` | How does the atmosphere respond to a given change of the sea surface? | The map |
| Earth orbit and paleoclimate | `obliquity`, `eccentricity`, `earth_sun_distance`, `paleo_231kyr` and two variants | How does the orbit of the Earth change the climate? | The map and the seasons. These runs give absolute values, not changes, so the notebook shows no Gregory plot. |
| Deconstruction | `decon_mean_climate`, `decon_2xco2` | Which process causes which part of the climate? | Switch processes off. This needs code: see the GREBClimate documentation. |

## Before you compare two runs

- Use the same control years and scenario years for both runs.
- A run must stay in range: `out_of_range` must be `(ctrl = nothing, scnr = nothing)`.
- A short run shows the fast response only. The ocean warms slowly, so the warming continues after 30 years.
- GREB is a simple model with fixed clouds and a fixed atmospheric circulation. Its result is an estimate. It can differ from the result of a full climate model.

## Order to try

1. `co2_double`: the reference experiment. Read the Gregory plot.
2. `co2_quadruple` and `co2_half`: is the response linear in the CO2 level, or in its logarithm?
3. `solar_plus27`: compare its map with that of `co2_double`.
4. A regional experiment: does the warming stay in the region?
