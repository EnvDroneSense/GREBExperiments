# Series helpers in src/series.jl.

@testset "gregory recovers a straight line" begin
    dT = collect(0.5:0.25:3.0)
    g = ET.gregory(dT, 5.0 .- 2.0 .* dT)
    @test g.forcing ≈ 5.0 && g.feedback ≈ -2.0 && g.sensitivity ≈ 2.5 && g.r2 ≈ 1
    @test g.reached == dT[end] && g.remaining ≈ 5.0 - 2.0 * dT[end]
    @test g.closure ≈ dT[end] / 2.5
    @test_throws ArgumentError ET.gregory([1.0, 2.0], [1.0, 2.0])
    @test_throws ArgumentError ET.gregory(fill(1.0, 5), collect(1.0:5.0))
    rising = @test_logs (:warn,) ET.gregory(dT, 1.0 .+ dT)
    @test isnan(rising.sensitivity) && isnan(rising.closure)
end

@testset "sine_fit finds amplitude, lag and mean" begin
    period, lag = 40, 5.0
    series = [2 + 3 * sin(2π * (t - lag) / period) for t in 0:159]
    fit = ET.sine_fit(series, period)
    @test fit.amplitude ≈ 3 && fit.lag ≈ lag && fit.mean ≈ 2
    # A true lag of 0.6 period comes back wrapped to -0.4 period
    wrapped = ET.sine_fit([sin(2π * (t - 0.6 * period) / period) for t in 0:159], period)
    @test wrapped.lag ≈ -0.4 * period
    @test_throws ArgumentError ET.sine_fit(ones(10), period)
end

@testset "annual means group by record time" begin
    times = record_times(1950, 30)
    records = [uniform_record(Float32(m)) for m in 1:30]
    years, values, dropped = ET.annual_means(records, times, :Ts)
    @test years == [1950, 1951] && dropped == [1952] # 1952 has six months only
    @test values ≈ [gmean(1:12), gmean(13:24)]
    @test ET.annual_means(records, times, rec -> 2 * rec.Ts[1, 1])[2] ≈ 2 .* values
    @test_throws DimensionMismatch ET.annual_means(records, times[1:5], :Ts)
    weights = Float64.([31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31])
    @test ET.annual_means(records, times, :Ts; month_weights=weights).values[1] ≈ sum(weights .* (1:12)) / sum(weights)
    @test_throws ArgumentError ET.annual_means(records, times, :Ts; month_weights=ones(11))
    # Two joined runs that repeat a year are refused
    @test_throws ArgumentError ET.annual_means([records; records[1:12]], [times; times[1:12]], :Ts)
end
