### A Pluto.jl notebook ###
# v1.0.3

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    return quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ d20597f1-1931-4121-9d4f-cb0f0455eeb8
begin
    import Pkg
    Pkg.activate(@__DIR__)
    using Plots, PlutoUI, GREBClimate, GREBExperiments
    # GREBViz is part of the GREBClimate clone and is not a package: include it.
    # Its names are used qualified, since some clash with GREBExperiments.
    include(joinpath(@__DIR__, "..", "..", "GREB-julia", "viz", "GREBViz.jl"))
    gr()
    md"*environment ready*"
end

# ╔═╡ 4d2054c1-d936-4ae9-b3f9-1aabc31cb6db
md"""
# Climate experiments with GREB

Pick an experiment, run it, and read the result. Each step has a short note on what you see.
"""

# ╔═╡ f3ba0bca-b8bd-44ed-b9c2-9535466dc414
begin
    data_dir = greb_data_dir(allow_download=false)
    fields = load_climatology(data_dir; dataset=:ncep)
end;

# ╔═╡ 97a5cdac-7c15-4591-8d7d-375e5426e472
md"""Experiment $(@bind experiment Select(preset_names(), default=:co2_double))

Control years $(@bind n_ctrl Slider(1:5, default=2, show_value=true))

Scenario years $(@bind n_scnr Slider(12:60, default=30, show_value=true))

Run the model $(@bind go CheckBox(default=false))"""

# ╔═╡ 79272818-948e-4f4d-ae13-73a3c9c4565e
result = go ? Base.CoreLogging.with_logger(Base.CoreLogging.NullLogger()) do
    greb_model!(RunSpec(ctrl=n_ctrl, scnr=n_scnr), preset(experiment; corrections=SpinUp(3));
        jld2_dir=data_dir, fields=fields)
end : nothing;

# ╔═╡ 3c311856-1a39-4f64-ab41-1a4ceedaf608
md"""## Did the run stay sensible?

`summarize` reduces the result to annual global means and checks that no value left the allowed range."""

# ╔═╡ 84f666c6-642e-4cb5-9251-17d25a38dd1c
summary = result === nothing ? nothing : summarize(result);

# ╔═╡ 497b0158-6522-4dd8-83f2-eb4a4320e8a5
summary === nothing ? md"Tick *Run the model* above." :
    (out_of_range = summary.out_of_range, last_year_Ts_change = summary.scnr.Ts[end] - summary.ctrl.Ts[end])

# ╔═╡ e844bb50-4e64-4a9e-8a7f-9617cacfcd2f
md"""## How sensitive is the climate?

Each dot is one year. The line is the fit of net flux against warming; where it reaches zero is the effective climate sensitivity. Only for experiments that give an anomaly, such as `co2_double`."""

# ╔═╡ 16359d25-0783-4a17-88f2-c3f0df3207da
if summary !== nothing && summary.scnr_anomaly
    plot_gregory(summary.scnr.Ts, summary.scnr.net)
end

# ╔═╡ 97be7c39-eda8-4973-9ee9-29810e970ee7
md"""## Where does it warm?"""

# ╔═╡ d9ba9809-b6d8-4933-b34d-a6d3dc4e44f4
result === nothing ? nothing : GREBViz.plot_map(result; var=:Ts, fields=fields)

# ╔═╡ 7824ab8a-b202-4b10-9bf7-177a4f6d86e2
result === nothing ? nothing : GREBViz.plot_timeseries(result; annual=true)

# ╔═╡ Cell order:
# ╟─d20597f1-1931-4121-9d4f-cb0f0455eeb8
# ╟─4d2054c1-d936-4ae9-b3f9-1aabc31cb6db
# ╟─f3ba0bca-b8bd-44ed-b9c2-9535466dc414
# ╟─97a5cdac-7c15-4591-8d7d-375e5426e472
# ╟─79272818-948e-4f4d-ae13-73a3c9c4565e
# ╟─3c311856-1a39-4f64-ab41-1a4ceedaf608
# ╟─84f666c6-642e-4cb5-9251-17d25a38dd1c
# ╟─497b0158-6522-4dd8-83f2-eb4a4320e8a5
# ╟─e844bb50-4e64-4a9e-8a7f-9617cacfcd2f
# ╟─16359d25-0783-4a17-88f2-c3f0df3207da
# ╟─97be7c39-eda8-4973-9ee9-29810e970ee7
# ╟─d9ba9809-b6d8-4933-b34d-a6d3dc4e44f4
# ╟─7824ab8a-b202-4b10-9bf7-177a4f6d86e2
