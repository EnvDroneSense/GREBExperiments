# Diagnostics of one (xdim, ydim) map. All means are area-weighted.

export area_mean, zonal_mean, polar_amplification, land_ocean, pattern_correlation

"""
    area_mean(map, mask=nothing)

Return the area-weighted mean of a (`xdim`, `ydim`) map. With a `Bool` mask, the
mean is over the cells where `mask` is `true`. A mask of numbers is a weight.

A map or mask of the wrong size throws a `DimensionMismatch`, so a transposed map
does not pass silently. A mask that selects no cell throws an `ArgumentError`.
"""
function area_mean(map::AbstractMatrix, mask=nothing)
    size(map) == (G.xdim, G.ydim) || throw(DimensionMismatch("expected a ($(G.xdim), $(G.ydim)) map, got $(size(map))"))
    mask === nothing || size(mask) == (G.xdim, G.ydim) ||
        throw(DimensionMismatch("expected a ($(G.xdim), $(G.ydim)) mask, got $(size(mask))"))
    w = mask === nothing ? WEIGHT : WEIGHT .* mask
    sum(w) > 0 || throw(ArgumentError("the mask selects no cell"))
    return sum(Float64.(map) .* w) / sum(w)
end

"""
    zonal_mean(map)

Return the mean over longitude of a (`xdim`, `ydim`) map: one value per latitude
row.
"""
function zonal_mean(map::AbstractMatrix)
    size(map) == (G.xdim, G.ydim) || throw(DimensionMismatch("expected a ($(G.xdim), $(G.ydim)) map, got $(size(map))"))
    return vec(sum(Float64.(map); dims=1)) ./ G.xdim
end

"""
    polar_amplification(map; latitude=60)

Return `(north, south, north_mean, south_mean, global_mean)`. `north_mean` and
`south_mean` are the area-weighted means of `map` poleward of `latitude` degrees
in each hemisphere. `north` and `south` are these means divided by
`global_mean`. A uniform map gives `north = south = 1.0`.

Give a change, not an absolute temperature: the cold poles give a ratio below 1
for any absolute map. When the global mean is near zero (a regional or residual
map), the ratio is very large or changes sign. Use the means then.
"""
function polar_amplification(map::AbstractMatrix; latitude::Real=60)
    lat = G.lat_grid
    rows(mask) = [mask[j] for _ in 1:G.xdim, j in 1:G.ydim]
    g = area_mean(map)
    n, s = area_mean(map, rows(lat .>= latitude)), area_mean(map, rows(lat .<= -latitude))
    return (north=n / g, south=s / g, north_mean=n, south_mean=s, global_mean=g)
end

"""
    land_ocean(map, z_topo)

Return `(land, ocean)`: the area-weighted means of `map` over the land cells and
over the ocean cells. The topography `z_topo` of the climatology sets which
cells are land.
"""
function land_ocean(map::AbstractMatrix, z_topo::AbstractMatrix)
    land = G.is_land.(z_topo)
    return (land=area_mean(map, land), ocean=area_mean(map, .!land))
end

"""
    pattern_correlation(a, b)

Return the area-weighted correlation of two maps, about their own weighted
means. A positive scale factor or a shift of a map does not change it. A constant
map has no pattern and throws an `ArgumentError`.
"""
function pattern_correlation(a::AbstractMatrix, b::AbstractMatrix)
    ma, mb = area_mean(a), area_mean(b)
    da, db = Float64.(a) .- ma, Float64.(b) .- mb
    va, vb = sum(WEIGHT .* da .^ 2), sum(WEIGHT .* db .^ 2)
    (va > 0 && vb > 0) || throw(ArgumentError("a constant map has no pattern to correlate"))
    return sum(WEIGHT .* da .* db) / sqrt(va * vb)
end
