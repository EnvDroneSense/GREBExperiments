# Write the `year ppm` text file that GREBClimate's `CO2File` reads.

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
