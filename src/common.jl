# Names that the other source files share. They reach four GREBClimate internals
# through `G.` (`dxlat_grid`, `lat_grid`, `is_land`, `RangeCheck`); do not add more.

const G = GREBClimate

# Area weight of each grid cell: the cell width changes with latitude.
const WEIGHT = [Float64(G.dxlat_grid[j]) for _ in 1:G.xdim, j in 1:G.ydim]
