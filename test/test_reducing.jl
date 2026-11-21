# Reducing a result in src/reducing.jl.

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
