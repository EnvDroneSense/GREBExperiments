using GREBExperiments
using Test

include("support.jl")

@testset "GREBExperiments.jl" begin
    include("test_maps.jl")
    include("test_series.jl")
    include("test_reducing.jl")
    include("test_io.jl")
    include("test_driver.jl")
end
