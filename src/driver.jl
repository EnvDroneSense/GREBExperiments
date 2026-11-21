# Run a set of model members and return one row per member; with `outdir` the rows
# go to a CSV file and a manifest (see io.jl).

export run_members

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
