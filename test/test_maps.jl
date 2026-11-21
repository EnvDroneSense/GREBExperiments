# Map diagnostics in src/maps.jl.

@testset "map diagnostics" begin
    ones_map = fill(1.0f0, X, Y)
    @test ET.area_mean(ones_map) ≈ 1
    @test ET.area_mean(ones_map) ≈ global_mean(ones_map)
    @test ET.zonal_mean(ones_map) == fill(1.0, Y)
    flat = ET.polar_amplification(ones_map)
    @test flat.north ≈ 1 && flat.south ≈ 1

    pole = [abs(lat_grid[j]) >= 60 ? 2.0f0 : 1.0f0 for _ in 1:X, j in 1:Y]
    amp = ET.polar_amplification(pole)
    @test amp.north ≈ amp.south > 1
    @test amp.north ≈ 2 / ET.area_mean(pole)

    z_topo = synthetic_fields().z_topo
    land = Float32.(is_land.(z_topo))
    @test any(land .== 1) && any(land .== 0)
    lo = ET.land_ocean(land, z_topo)
    @test lo.land ≈ 1 && abs(lo.ocean) < 1e-12
    @test ET.area_mean(land, land .== 1) ≈ 1
    @test_throws ArgumentError ET.area_mean(land, falses(X, Y))

    a = [Float32(sin(i / 7) + cos(j / 5)) for i in 1:X, j in 1:Y]
    @test ET.pattern_correlation(a, a) ≈ 1
    @test ET.pattern_correlation(a, 3 .* a .+ 2) ≈ 1
    @test ET.pattern_correlation(a, -a) ≈ -1
    @test_throws DimensionMismatch ET.area_mean(zeros(Float32, 3, 3))
    @test_throws DimensionMismatch ET.area_mean(a, trues(3, 3))
    @test_throws DimensionMismatch ET.zonal_mean(zeros(Float32, 3, 3))
    @test_throws ArgumentError ET.pattern_correlation(ones_map, a)
    # Two weight implementations agree on a map that is not constant
    @test ET.area_mean(a) ≈ global_mean(a)
    # Zero global mean: the ratio is meaningless, the means are still given
    zero_mean = a .- Float32(ET.area_mean(a))
    @test abs(ET.polar_amplification(zero_mean).global_mean) < 1e-5
end
