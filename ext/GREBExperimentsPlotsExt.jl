# The methods of the plot stubs in src/plots.jl. Julia loads them with Plots.jl.
module GREBExperimentsPlotsExt

using GREBExperiments: GREBExperiments, gregory
using Plots: Plots

function GREBExperiments.plot_response(rows::AbstractVector{<:NamedTuple}; x::Symbol=:co2_ppm,
        y::Symbol=:Ts_anom_K, xlog::Bool=false)
    isempty(rows) && throw(ArgumentError("no rows to plot"))
    (haskey(rows[1], x) && haskey(rows[1], y)) ||
        throw(ArgumentError("rows have the columns $(keys(rows[1])), not $x and $y"))
    return Plots.plot([r[x] for r in rows], [r[y] for r in rows]; marker=:circle, legend=false,
        xlabel=string(x), ylabel=string(y), xscale=xlog ? :log10 : :identity)
end

function GREBExperiments.plot_gregory(dTs::AbstractVector{<:Real}, dnet::AbstractVector{<:Real})
    g = gregory(dTs, dnet)
    p = Plots.scatter(dTs, dnet; label="annual means", xlabel="warming [K]", ylabel="net flux change [W/m2]")
    # Draw the line to its zero crossing; without a crossing, to the largest warming.
    xs = [0.0, isnan(g.sensitivity) ? maximum(dTs) : g.sensitivity]
    Plots.plot!(p, xs, g.forcing .+ g.feedback .* xs; label="fit: $(round(g.feedback; digits=2)) W/m2/K")
    isnan(g.sensitivity) || Plots.scatter!(p, [g.sensitivity], [0.0]; label="sensitivity $(round(g.sensitivity; digits=2)) K", marker=:star5)
    return p
end

end # module
