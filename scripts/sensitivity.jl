# Effective climate sensitivity of an abrupt-CO2 run, from its monthly records.
#
#   julia --project=. -t 2,0 scripts/sensitivity.jl [preset] [scenario years] [spin-up years] [control years]
#
# Defaults: co2_double, 100 scenario years, 3 spin-up years, 2 control years.
# The control repeats one year, so more control years add nothing. The script
# runs the preset on the NCEP climatology and gives the annual global means to
# `gregory`. It prints the forcing, feedback, effective sensitivity, r2, the
# warming reached and the net flux that remains.
#
# For co2_double and 100 years: 5.06 W/m2, -1.88 W/m2/K, 2.69 K, 3.00 K reached.
# The script needs the local dataset and a preset whose scenario is an anomaly.

using GREBClimate
using Printf
using GREBExperiments: summarize, gregory

function main(args)
    name = Symbol(get(args, 1, "co2_double"))
    years = parse(Int, get(args, 2, "100"))
    spinup = parse(Int, get(args, 3, "3"))
    ctrl = parse(Int, get(args, 4, "2"))

    dir = greb_data_dir(; allow_download=false)
    dir === nothing && error("no local dataset found")
    fields = load_climatology(dir; dataset=:ncep)
    result = greb_model!(RunSpec(ctrl=ctrl, scnr=years), preset(name; corrections=SpinUp(spinup));
        jld2_dir=dir, fields=fields)
    result.scnr_anomaly || error("the scenario of `$name` is not an anomaly")

    s = summarize(result)
    for phase in (:ctrl, :scnr)
        flag = s.out_of_range[phase]
        flag === nothing || @warn "the $phase run left the allowed range" flag
    end
    g = gregory(s.scnr.Ts, s.scnr.net)
    @printf("%s, %d scenario years, spin-up %d, control %d\n", name, years, spinup, ctrl)
    @printf("  forcing                %7.2f W/m2\n", g.forcing)
    @printf("  feedback               %7.2f W/m2/K\n", g.feedback)
    @printf("  effective sensitivity  %7.2f K\n", g.sensitivity)
    @printf("  r2                     %7.3f\n", g.r2)
    @printf("  warming reached        %7.2f K\n", g.reached)
    @printf("  net flux remaining     %7.2f W/m2\n", g.remaining)
    return g
end

if abspath(PROGRAM_FILE) == @__FILE__
    main(ARGS)
end
