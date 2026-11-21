using GREBExperiments
using Test

include("support.jl")

@testset "GREBExperiments.jl" begin
    include("test_helpers.jl")
    include("test_co2file.jl")
    include("test_driver.jl")
end
