# GREBExperiments

Experiments and analysis tools built on [GREBClimate.jl](https://github.com/EnvDroneSense/GREBClimate.jl), the GREB climate model. The model package stays stable. Work that asks a question of the model, or that changes frequently, is in this repository.

This repository holds a Julia package, `GREBExperiments`, and scripts. The package runs sets of model members and reduces each result to a few numbers. The scripts use the package to answer one question each.

## Installation

Requires Julia 1.10 or later. The package is not registered; work from a clone:

```bash
git clone https://github.com/EnvDroneSense/GREBExperiments.git
cd GREBExperiments
julia --project=. -e 'using Pkg; Pkg.instantiate()'
```

`GREBClimate` is pinned to one minor version (`~2.3` in `Project.toml`). The helpers use some names that the model package does not export, so a new model release can break them. Raise the pin only after the tests pass against the new release.

The scripts need a local copy of the input dataset of the model and never download it. See the GREBClimate documentation.

## Where to go next

| Page | For |
|:-----|:----|
| [Running the scripts](@ref) | The two scripts, their arguments and what they print |
| [Reducing a run](@ref) | Reduce a `greb_model!` result to annual global means and check that it stayed in range |
| [Climate sensitivity](@ref) | The Gregory estimate of forcing, feedback and sensitivity |
| [Map diagnostics](@ref) | Area-weighted means, zonal means, polar amplification, land and ocean, pattern correlation |
| [Fitting a cycle](@ref) | Amplitude, lag and mean of a periodic response |
| [Plots and the notebook](@ref) | The two experiment plots and the Pluto notebook for students |
| [API Reference](@ref) | The docstring of each exported function |
