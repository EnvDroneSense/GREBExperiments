# src/io.jl: co2_file writes what GREBClimate reads back.

@testset "co2_file round trip" begin
    mktempdir() do dir
        path = joinpath(dir, "co2.txt")
        years, ppm = [1950, 1951, 1952], [280.0, 285.5, 560.25]
        @test ET.co2_file(path, years, ppm) == path
        table = GREBClimate.load_co2_custom(path)
        @test sort(collect(keys(table))) == years
        @test [table[y] for y in years] == Float32.(ppm)
    end
    mktempdir() do dir
        path = joinpath(dir, "bad.txt")
        @test_throws DimensionMismatch ET.co2_file(path, [1950, 1951], [280.0])
        @test_throws ArgumentError ET.co2_file(path, Int[], Float64[])
        @test_throws ArgumentError ET.co2_file(path, [1950, 1950], [280.0, 281.0])
        @test_throws ArgumentError ET.co2_file(path, [1950], [NaN])
        @test_throws ArgumentError ET.co2_file(path, [1950], [-1.0])
        @test !isfile(path)
    end
end
