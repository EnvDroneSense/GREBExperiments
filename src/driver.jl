# Run a set of model members and write one row per member to a CSV file, with a
# manifest that records how the rows were made. Needs only standard libraries.

const MANIFEST_VERSION = 1

"""
    run_members(reduce, run, configs; labels, outdir=nothing, name="members",
                fields, jld2_dir="", ntasks=Threads.nthreads(), kwargs...)

Run each of `configs` with `run` (a `RunSpec`) through `GREBClimate.run_ensemble`
and return one row per member: the `labels[i]` (a `NamedTuple` of scalars that
identify the member) merged with `reduce(result)` (a `NamedTuple` of scalars).
`reduce` runs in the member's task, so only its few numbers stay in memory.

When `outdir` is given, it also writes `outdir/<name>.csv` (one line per row; a
`NaN` is written as `NaN`) and `outdir/<name>_manifest.toml` with the package
versions, the run lengths, the column names, the configuration of each member
and the time. `kwargs` go on to `run_ensemble`. All members must give the same
column names; a different set throws an `ArgumentError`, before anything is
written.
"""
function run_members(reduce, run::G.RunSpec, configs; labels::AbstractVector{<:NamedTuple},
        outdir::Union{Nothing,AbstractString}=nothing, name::AbstractString="members", kwargs...)
    members = collect(configs)
    length(labels) == length(members) ||
        throw(DimensionMismatch("$(length(members)) configs, $(length(labels)) labels"))
    isempty(members) && throw(ArgumentError("need at least one member"))
    reduced = G.run_ensemble(reduce, run, members; kwargs...)
    rows = [merge(l, r) for (l, r) in zip(labels, reduced)]
    columns = keys(rows[1])
    all(r -> keys(r) == columns, rows) ||
        throw(ArgumentError("the members give different columns: $(unique(keys.(rows)))"))
    outdir === nothing || write_members(outdir, name, rows, run, members)
    return rows
end

"""
    write_members(outdir, name, rows, run, configs)

Write the CSV and the manifest that [`run_members`](@ref) writes. Returns the
CSV path.
"""
function write_members(outdir::AbstractString, name::AbstractString, rows, run, configs)
    mkpath(outdir)
    columns = collect(keys(rows[1]))
    csv = joinpath(outdir, name * ".csv")
    open(csv, "w") do io
        println(io, join(columns, ","))
        for r in rows
            println(io, join((_csv_cell(r[c]) for c in columns), ","))
        end
    end
    manifest = Dict{String,Any}(
        "manifest_version" => MANIFEST_VERSION,
        "written" => string(Dates.now()),
        "julia" => string(VERSION),
        "GREBClimate" => string(pkgversion(G)),
        "GREBExperiments" => string(pkgversion(@__MODULE__)),
        "threads" => Threads.nthreads(),
        "csv" => basename(csv),
        "columns" => string.(columns),
        "run" => Dict{String,Any}("ctrl" => run.ctrl, "scnr" => run.scnr),
        "members" => [Dict{String,Any}("index" => i, "config" => repr(c)) for (i, c) in enumerate(configs)])
    open(joinpath(outdir, name * "_manifest.toml"), "w") do io
        TOML.print(io, manifest)
    end
    return csv
end

# A cell holds a number, a bool or a short string; a comma or quote in a string
# would break the line, so it is refused
_csv_cell(x::Union{Real,Bool}) = string(x)
_csv_cell(::Nothing) = ""
function _csv_cell(x::AbstractString)
    any(c -> c in (',', '"', '\n'), x) && throw(ArgumentError("a CSV cell must not contain a comma, quote or newline: $x"))
    return String(x)
end
_csv_cell(x::Symbol) = _csv_cell(string(x))
