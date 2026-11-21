# run_members on the synthetic climate: rows, CSV and manifest.

@testset "run_members" begin
    configs = [preset(:co2_double; corrections=NoCorrections()), preset(:co2_half; corrections=NoCorrections())]
    labels = [(label="double",), (label="half",)]
    reduce(result) = (Ts=gmean([global_mean(r.Ts) for r in result.scnr[1:12]]), n=length(result.scnr))
    run = RunSpec(ctrl=1, scnr=1)
    mktempdir() do dir
        rows = quiet() do
            run_members(reduce, run, configs; labels, outdir=dir, name="t",
                fields=synthetic_fields(), jld2_dir="", ntasks=1, allow_uninitialized=true)
        end
        @test [r.label for r in rows] == ["double", "half"] && all(r.n == 12 for r in rows)
        lines = readlines(joinpath(dir, "t.csv"))
        @test lines[1] == "label,Ts,n" && length(lines) == 3 && startswith(lines[2], "double,")
        m = ET.TOML.parsefile(joinpath(dir, "t_manifest.toml"))
        @test m["columns"] == ["label", "Ts", "n"] && m["run"]["scnr"] == 1 && length(m["members"]) == 2
        @test m["GREBClimate"] == string(pkgversion(GREBClimate)) && m["csv"] == "t.csv"
    end
    @test_throws DimensionMismatch run_members(reduce, run, configs; labels=labels[1:1], fields=synthetic_fields())
    @test_throws ArgumentError ET._csv_cell("a,b")
    @test ET._csv_cell(nothing) == "" && ET._csv_cell(NaN) == "NaN" && ET._csv_cell(:x) == "x"
end
