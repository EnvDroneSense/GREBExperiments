# src/plots.jl: the plot methods exist only when Plots.jl is loaded.

if Base.get_extension(GREBExperiments, :GREBExperimentsPlotsExt) === nothing
    @testset "plots need Plots.jl" begin
        @test_throws MethodError ET.plot_response([(co2_ppm=280.0, Ts_anom_K=0.0)])
        @test_throws MethodError ET.plot_gregory([1.0, 2.0, 3.0], [3.0, 2.0, 1.0])
    end
else
    @testset "plots with Plots.jl" begin
        rows = [(co2_ppm=c, Ts_anom_K=log2(c / 280)) for c in (140.0, 280.0, 560.0)]
        @test ET.plot_response(rows; xlog=true) isa Main.Plots.Plot
        @test_throws ArgumentError ET.plot_response(rows; y=:missing)
        dT = collect(0.5:0.25:3.0)
        @test ET.plot_gregory(dT, 5.0 .- 2.0 .* dT) isa Main.Plots.Plot
    end
end
