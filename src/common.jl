# Shared by the other source files: the model package under a short name and the
# area weights of the grid. The files reach four GREBClimate internals as `G.`
# (`dxlat_grid`, `lat_grid`, `is_land`, `RangeCheck`); do not add more.

const G = GREBClimate

const WEIGHT = [Float64(G.dxlat_grid[j]) for _ in 1:G.xdim, j in 1:G.ydim]
