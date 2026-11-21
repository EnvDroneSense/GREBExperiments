# Diagnostics of a (xdim, ydim) map. Pure functions; every mean is area-weighted.

export area_mean, zonal_mean, polar_amplification, land_ocean, pattern_correlation

"""
    area_mean(map, mask=nothing)

Area-weighted mean of a (`xdim`, `ydim`) map, over the cells where `mask` is
`true` when a mask is given. A mask of another type is used as a weight.
"""
function area_mean(map::AbstractMatrix, mask=nothing)
    size(map) == (G.xdim, G.ydim) || throw(DimensionMismatch("expected a ($(G.xdim), $(G.ydim)) map, got $(size(map))"))
    mask === nothing || size(mask) == (G.xdim, G.ydim) ||
        throw(DimensionMismatch("expected a ($(G.xdim), $(G.ydim)) mask, got $(size(mask))"))
    w = mask === nothing ? WEIGHT : WEIGHT .* mask
    sum(w) > 0 || throw(ArgumentError("the mask selects no cell"))
    return sum(Float64.(map) .* w) / sum(w)
end

"The mean over longitude of a map: one value per latitude row."
function zonal_mean(map::AbstractMatrix)
    size(map) == (G.xdim, G.ydim) || throw(DimensionMismatch("expected a ($(G.xdim), $(G.ydim)) map, got $(size(map))"))
    return vec(sum(Float64.(map); dims=1)) ./ G.xdim
end

"""
    polar_amplification(map; latitude=60)

`(north, south, north_mean, south_mean, global_mean)`: `north` and `south` are
the mean of `map` poleward of `latitude` degrees over its global mean, for each
hemisphere; the other three are the means themselves. A uniform map gives
`north = south = 1.0`. When the global mean is near zero (a regional or residual
map) the ratio is very large or changes sign: use the means then.
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

`(land, ocean)`: the area-weighted means of `map` over the land and the ocean
cells, land being where the topography `z_topo` says so.
"""
function land_ocean(map::AbstractMatrix, z_topo::AbstractMatrix)
    land = G.is_land.(z_topo)
    return (land=area_mean(map, land), ocean=area_mean(map, .!land))
end

"""
Area-weighted correlation of two maps, about their own weighted means. A
constant map has no pattern: it throws an `ArgumentError`.
"""
function pattern_correlation(a::AbstractMatrix, b::AbstractMatrix)
    ma, mb = area_mean(a), area_mean(b)
    da, db = Float64.(a) .- ma, Float64.(b) .- mb
    va, vb = sum(WEIGHT .* da .^ 2), sum(WEIGHT .* db .^ 2)
    (va > 0 && vb > 0) || throw(ArgumentError("a constant map has no pattern to correlate"))
    return sum(WEIGHT .* da .* db) / sqrt(va * vb)
end
