# Files that the package writes. Only standard libraries, so no new dependency.

export co2_file

# Increase when the layout of the manifest changes.
const MANIFEST_VERSION = 1

"""
    co2_file(path, years, values)

Write a CO2 path as a text file of `year ppm` lines and return `path`.
`CO2File(path)` and `load_co2_custom` read this file.

`years` and `values` must have the same length. Each year must occur only once.
Each value [ppm] must be finite and positive. The file holds the values at
`Float32` precision, because the model reads them at that precision.
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

Write the CSV file and the manifest of [`run_members`](@ref), and return the
path of the CSV file.
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

# The CSV has no quoting, so a string with a comma, quote or newline is refused.
_csv_cell(x::Union{Real,Bool}) = string(x)
_csv_cell(::Nothing) = ""
function _csv_cell(x::AbstractString)
    any(c -> c in (',', '"', '\n'), x) && throw(ArgumentError("a CSV cell must not contain a comma, quote or newline: $x"))
    return String(x)
end
_csv_cell(x::Symbol) = _csv_cell(string(x))
