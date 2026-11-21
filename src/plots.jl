# Plots of experiment results. The methods are in `ext/GREBExperimentsPlotsExt.jl`
# and load when Plots.jl is loaded, so the package and its tests need no plotting
# package. Plots of a whole run (maps, time series) are in GREBViz, in GREBClimate.

export plot_response, plot_gregory

"""
    plot_response(rows; x=:co2_ppm, y=:Ts_anom_K, xlog=false)

Plot column `y` against column `x` of `rows`, a vector of `NamedTuple`s such as
`run_members` returns. Needs Plots.jl: run `using Plots` first. `xlog=true` puts
`x` on a log axis, as for CO2. Returns the plot.
"""
function plot_response end

"""
    plot_gregory(dTs, dnet)

Plot the annual net-flux change `dnet` [W/m2] against the warming `dTs` [K], with
the line that [`gregory`](@ref) fits and its crossing of zero, the effective
sensitivity. Needs Plots.jl: run `using Plots` first. Returns the plot.
"""
function plot_gregory end

function __init__()
    Base.Experimental.register_error_hint(MethodError) do io, exc, argtypes, kwargs
        if exc.f in (plot_response, plot_gregory) && !any(k -> k.name == "Plots", keys(Base.loaded_modules))
            print(io, "\n$(exc.f) needs Plots.jl: run `using Plots` first.")
        end
    end
end
