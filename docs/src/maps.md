# Map diagnostics

The model grid is 96 x 48 in longitude and latitude. A cell near the pole covers less area than a cell on the equator, so a plain mean over the cells overweights the poles. Every function on this page weights by the area of the cell. They take a `(96, 48)` matrix, or fewer cells selected by a mask, and none runs the model.

| Function | Returns |
|:---------|:--------|
| [`area_mean`](@ref) | The area-weighted mean of a map, optionally over a mask |
| [`zonal_mean`](@ref) | The mean over longitude: one value per latitude row |
| [`polar_amplification`](@ref) | The mean poleward of a latitude, north and south, divided by the global mean |
| [`land_ocean`](@ref) | The area-weighted means over land and over ocean |
| [`pattern_correlation`](@ref) | The area-weighted correlation of two maps |

## Means

```jldoctest
julia> using GREBExperiments, GREBClimate

julia> map = fill(1.0f0, xdim, ydim);

julia> area_mean(map)
1.0

julia> zonal_mean(map)[1:3]
3-element Vector{Float64}:
 1.0
 1.0
 1.0
```

A mask selects the cells. `area_mean(map, mask)` averages over the cells where `mask` is `true` and throws an `ArgumentError` when it selects none. A map of the wrong size throws a `DimensionMismatch`, so a transposed map does not pass silently.

## Polar amplification

`polar_amplification(map; latitude=60)` returns `(north, south)`: the mean of the map poleward of `latitude` degrees divided by its global mean, for each hemisphere. A uniform map gives `(1.0, 1.0)`; a warming that is twice as strong near the poles gives a value above 1. Give it a temperature change, not an absolute temperature, since the cold poles would otherwise give a number below 1 for any map.

```jldoctest
julia> using GREBExperiments, GREBClimate

julia> polar_amplification(fill(1.0f0, xdim, ydim))
(north = 1.0, south = 1.0)
```

## Land and ocean

`land_ocean(map, z_topo)` returns `(land, ocean)`, the area-weighted means over the cells that are land and over the cells that are ocean. Land is where the topography `z_topo`, which the model reads with the climatology, says so. Use it for the usual question of whether land warms faster than ocean.

## Comparing two patterns

`pattern_correlation(a, b)` is the correlation of two maps about their own area-weighted means. It does not depend on the amplitude of either map: a map and three times the map plus two correlate at 1.

```jldoctest
julia> using GREBExperiments, GREBClimate

julia> a = [Float32(sin(i / 7) + cos(j / 5)) for i in 1:xdim, j in 1:ydim];

julia> round(pattern_correlation(a, 3 .* a .+ 2); digits = 6)
1.0

julia> round(pattern_correlation(a, -a); digits = 6)
-1.0
```

Use it to ask whether two experiments warm the same places, for example CO2 against a change in the solar constant at the same forcing, while the global means differ.
