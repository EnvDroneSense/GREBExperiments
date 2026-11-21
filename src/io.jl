# Files the package writes: the CO2 file that GREBClimate's `CO2File` reads, and
# the CSV and manifest of `run_members`. Standard libraries only.

export co2_file

const MANIFEST_VERSION = 1

"""
    co2_file(path, years, values)

Write a CO2 path as a text file of `year ppm` lines that `CO2File(path)` and
`load_co2_custom` read, and return `path`. `years` must be integers that do not
repeat, `values` finite and positive [ppm], and both the same length. Values are
written at `Float32` precision, which is what the model reads.
"""
function co2_file(path::AbstractString, years::AbstractVector{<:Integer}, values::AbstractVector{<:Real})
    length(years) == length(values) || throw(DimensionMismatch("$(length(years)) years, $(length(values)) values"))
    isempty(years) && throw(ArgumentError("need at least one year"))
    allunique(years) || throw(ArgumentError("a year occurs twice"))
    all(v -> isfinite(v) && v > 0, values) || throw(ArgumentError("CO2 values must be finite and positive"))
    open(path, "w") do io
        for (y, v) in zip(years, values)
            println(io, y, " ", Float32(v))
        end
    end
    return path
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
