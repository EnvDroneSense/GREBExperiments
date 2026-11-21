# Climate response over a range of CO2 levels.
#
#   julia --project=. -t 4,0 scripts/co2_sweep.jl [levels] [scenario years] [spin-up years] [control years]
#
# Defaults: 5 levels, 30 scenario years, 3 spin-up years, 5 control years.
# The levels are log-spaced from 170 ppm (:co2_half) to 3400 ppm (:co2_10x); the
# control is at 280 ppm. For each level, the script prints the anomaly of the
# last scenario year (global-mean Ts, ice cover, precipitation) and whether a
# record left the allowed range. It writes the rows to scripts/out/co2_sweep.csv.
#
# A full curve (`... 20 100`) takes hours. The script needs the local dataset and
# several threads. Each running level holds 370 MB of fields.

using GREBClimate
using GREBExperiments: annual_means, in_range_report, run_members

function main(args)
    levels = parse(Int, get(args, 1, "5"))
    years = parse(Int, get(args, 2, "30"))
    spinup = parse(Int, get(args, 3, "3"))
    ctrl = parse(Int, get(args, 4, "5"))
    years >= 12 || error("need at least 12 scenario years to take a last-year mean")

    dir = greb_data_dir(; allow_download=false)
    dir === nothing && error("no local dataset found")
    fields = load_climatology(dir; dataset=:ncep)
    control_co2 = 280
    co2 = levels == 1 ? [170.0] : exp10.(range(log10(170.0), log10(3400.0), length=levels))
    configs = [Config(scenario=Scenario(co2=ConstantCO2(c), control_co2=control_co2), corrections=SpinUp(spinup))
               for c in co2]

    # Keep only the last-year anomalies, so a member frees its fields when it ends.
    last_year(result, field) = annual_means(result.scnr, result.scnr_time, field)[2][end]
    labels = [(co2_ppm=c, control_co2_ppm=control_co2) for c in co2]
    rows = run_members(RunSpec(ctrl=ctrl, scnr=years), configs; labels, fields, jld2_dir=dir,
        outdir=joinpath(@__DIR__, "out"), name="co2_sweep") do result
        (Ts_anom_K=last_year(result, :Ts), ice_anom_frac=last_year(result, :ice), precip_anom=last_year(result, :precip),
            out_of_range=in_range_report(result.scnr, result.scnr_time, result.scnr_anomaly) !== nothing)
    end
    csv = joinpath(@__DIR__, "out", "co2_sweep.csv")
    any(r -> r.out_of_range, rows) && @warn "a member left the allowed range: see the out_of_range column"
    println("control CO2 = ", control_co2, " ppm")
    println(lpad("CO2 [ppm]", 10), lpad("Ts [K]", 10), lpad("ice", 10), lpad("precip", 10))
    for r in rows
        println(lpad(round(r.co2_ppm, digits=0), 10), lpad(round(r.Ts_anom_K, digits=2), 10),
            lpad(round(r.ice_anom_frac, digits=4), 10), lpad(round(r.precip_anom, digits=3), 10))
    end
    println("\nwrote ", csv, " and co2_sweep_manifest.toml")
    return rows
end

if abspath(PROGRAM_FILE) == @__FILE__
    main(ARGS)
end
