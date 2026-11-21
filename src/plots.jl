# Stubs only: the methods are in `ext/GREBExperimentsPlotsExt.jl`, so the package
# and its tests need no plotting package. For plots of a whole run, use GREBViz.

export plot_response, plot_gregory

"""
    plot_response(rows; x=:co2_ppm, y=:Ts_anom_K, xlog=false)

Plot column `y` against column `x` of `rows` and return the plot. `rows` is a
vector of `NamedTuple`s, as [`run_members`](@ref) returns. `xlog=true` puts `x`
on a log axis, for example for CO2. Run `using Plots` first.
"""
function plot_response end

"""
    plot_gregory(dTs, dnet)

Plot the annual net-flux change `dnet` [W/m2] against the warming `dTs` [K] and
return the plot. The plot also shows the line that [`gregory`](@ref) fits and
the point where the line crosses zero, the effective sensitivity. Run
`using Plots` first.
"""
function plot_gregory end

# Without Plots.jl the stubs have no method: tell the user what to load.
function __init__()
    Base.Experimental.register_error_hint(MethodError) do io, exc, argtypes, kwargs
        if exc.f in (plot_response, plot_gregory) && !any(k -> k.name == "Plots", keys(Base.loaded_modules))
            print(io, "\n$(exc.f) needs Plots.jl: run `using Plots` first.")
        end
    end
end
