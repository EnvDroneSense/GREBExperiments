export run_members

"""
    run_members(reduce, run, configs; labels, outdir=nothing, name="members",
                fields, jld2_dir="", ntasks=Threads.nthreads(), kwargs...)

Run each member of `configs` with `run` (a `RunSpec`) through
`GREBClimate.run_ensemble` and return one row per member. A row is `labels[i]`
merged with `reduce(result)`. Both are `NamedTuple`s of scalars: the labels
identify the member, and `reduce` gives the numbers to keep. `reduce` runs in
the task of the member, so only these numbers stay in memory.

With `outdir`, the function also writes `outdir/<name>.csv` (one line per row,
`NaN` as `NaN`) and `outdir/<name>_manifest.toml`. The manifest holds the
package versions, the run lengths, the column names, the configuration of each
member and the time. The other keyword arguments go to `run_ensemble`.

`labels` must have one entry per member, or the function throws a
`DimensionMismatch`. All members must give the same column names, or the
function throws an `ArgumentError` before it writes a file.
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
