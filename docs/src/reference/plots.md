# Experiment plots

GREBExperiments has two plots for experiment results. For plots of a whole run (maps, time series, Hovmoller diagrams, animations), use GREBViz in the GREBClimate repository.

| Function | Plots |
|:---------|:------|
| [`plot_response`](@ref) | A column of the rows from [`run_members`](@ref) against another column, for example the warming against CO2 |
| [`plot_gregory`](@ref) | The net-flux change against the warming, with the line that [`gregory`](@ref) fits |

Both functions need Plots.jl. The package does not depend on Plots.jl: the methods load when you run `using Plots`. Thus the tests need no plotting package.

```julia
using GREBExperiments, Plots

rows = [(co2_ppm = c, Ts_anom_K = log2(c / 280)) for c in (140.0, 280.0, 560.0)]
plot_response(rows; xlog = true)
```

## The notebook

`notebooks/climate_experiments.jl` is the Pluto notebook for students. [Getting started](@ref) tells how to open it. It has its own environment in `notebooks/Project.toml`, so the package needs neither Pluto nor Plots. It includes GREBViz from `../GREB-julia/viz` and uses the GREBViz names with a `GREBViz.` prefix, because `zonal_mean` is in both packages.
