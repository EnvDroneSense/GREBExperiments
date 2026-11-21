# The helpers in src/helpers.jl.

const ET = GREBExperiments

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

@testset "in_range_report" begin
    times = record_times(1950, 3)
    fine = [uniform_record(280.0f0; q=0.01f0) for _ in 1:3]
    @test ET.in_range_report(fine, times, false) === nothing
    runaway = [fine[1], uniform_record(280.0f0; q=0.01f0, Ts=1.0f24), fine[3]]
    @test ET.in_range_report(runaway, times, false) == (year=1950, month=2, field=:Ts, value=1.0f24)
    nan = [fine[1], fine[2], uniform_record(280.0f0; q=0.01f0, Ta=NaN32)]
    @test ET.in_range_report(nan, times, false).month == 3
    # An anomaly of a few kelvin is fine; the absolute range does not apply to it
    small = [uniform_record(2.0f0; q=0.001f0) for _ in 1:3]
    @test ET.in_range_report(small, times, true) === nothing
    @test ET.in_range_report(small, times, false).field == :Ts
    @test ET.in_range_report([uniform_record(1.0f24; q=0.001f0)], times[1:1], true).field == :Ts
    # A run that diverged by 100 K is caught, not hidden inside the absolute range width
    @test ET.in_range_report([uniform_record(100.0f0; q=0.001f0)], times[1:1], true).field == :Ts
    @test ET.in_range_report([uniform_record(100.0f0; q=0.001f0)], times[1:1], true;
        anomaly_limits=(Ts=200.0, Ta=200.0, To=200.0, q=0.08)) === nothing
end

@testset "summarize reduces a model result" begin
    result = run_synthetic(RunSpec(ctrl=1, scnr=2), preset(:co2_double; corrections=NoCorrections()))
    s = ET.summarize(result)
    @test s.scnr_anomaly && s.ctrl.years == [1970] && s.scnr.years == [1950, 1951]
    @test all(length(s.scnr[k]) == 2 for k in (:Ts, :precip, :ice, :net))
    @test s.ctrl.Ts[1] ≈ gmean([global_mean(r.Ts) for r in result.ctrl])
    @test s.scnr.net[2] ≈ gmean([global_mean(r.sw) - global_mean(r.olr) for r in result.scnr[13:24]])
    # The synthetic fields are not a climate: the scenario drifts about 100 K from
    # its control, which the anomaly limit catches
    @test isnan(s.drift)                             # one control year: no drift to measure
    @test s.out_of_range.ctrl === nothing && s.out_of_range.scnr.field == :Ts

    # A scenario can leave the range while its control is fine
    broken = merge(result, (scnr=[uniform_record(1.0f24; q=0.001f0); result.scnr[2:end]],))
    @test ET.summarize(broken).out_of_range.ctrl === nothing
    @test ET.summarize(broken).out_of_range.scnr.field == :Ts
end
