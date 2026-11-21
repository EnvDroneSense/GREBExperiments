# Map diagnostics

The model grid is 96 x 48 in longitude and latitude. A cell near the pole covers less area than a cell on the equator, so a plain mean over the cells gives too much weight to the poles. Each function on this page weights by the area of the cell. None of them runs the model.

| Function | Returns |
|:---------|:--------|
| [`area_mean`](@ref) | The area-weighted mean of a map, optionally over a mask |
| [`zonal_mean`](@ref) | The mean over longitude: one value per latitude row |
| [`polar_amplification`](@ref) | The polar means, north and south, divided by the global mean |
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

A mask selects the cells of the mean, for example the cells of one region.

## Polar amplification

A warming that is two times stronger near the poles gives a [`polar_amplification`](@ref) ratio above 1. A uniform map gives 1:

```jldoctest
julia> using GREBExperiments, GREBClimate

julia> polar_amplification(fill(1.0f0, xdim, ydim))
(north = 1.0, south = 1.0, north_mean = 1.0, south_mean = 1.0, global_mean = 1.0)
```

## Land and ocean

Use [`land_ocean`](@ref) to find if land warms faster than ocean. The model reads the topography `z_topo` with the climatology.

## Comparing two patterns

[`pattern_correlation`](@ref) does not depend on the amplitude of either map: a map and three times the map plus two correlate at 1.

```jldoctest
julia> using GREBExperiments, GREBClimate

julia> a = [Float32(sin(i / 7) + cos(j / 5)) for i in 1:xdim, j in 1:ydim];

julia> round(pattern_correlation(a, 3 .* a .+ 2); digits = 6)
1.0

julia> round(pattern_correlation(a, -a); digits = 6)
-1.0
```

Use it to find if two experiments warm the same places when their global means differ. An example is CO2 against a change in the solar constant at the same forcing.
