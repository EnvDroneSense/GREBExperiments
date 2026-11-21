# Plots and the notebook

GREBExperiments has two plots for experiment results. GREBViz, in the GREBClimate repository, plots a whole run (maps, time series, Hovmoller diagrams, animations). Use it for that, not these.

| Function | Plots |
|:---------|:------|
| [`plot_response`](@ref) | A column of the rows from [`run_members`](@ref) against another, for example the warming against CO2 |
| [`plot_gregory`](@ref) | The net-flux change against the warming, with the line that [`gregory`](@ref) fits |

Both need Plots.jl. The package does not depend on it: the methods load when you run `using Plots`, so the tests need no plotting package.

```julia
using GREBExperiments, Plots

rows = [(co2_ppm = c, Ts_anom_K = log2(c / 280)) for c in (140.0, 280.0, 560.0)]
plot_response(rows; xlog = true)
```

## The notebook

`notebooks/climate_experiments.jl` is a Pluto notebook for students. It lets you pick an experiment and the run length, runs the model, checks the result, and shows the Gregory plot, a map and the time series. It needs the local dataset and a clone of GREBClimate beside this repository.

```bash
julia notebooks/setup.jl
julia --project=notebooks -e 'using Pluto; Pluto.run(notebook="notebooks/climate_experiments.jl")'
```

The notebook uses the GREBViz names with a `GREBViz.` prefix, since `zonal_mean` exists in both packages.
