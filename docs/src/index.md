# GREBExperiments

Experiments and analysis tools built on [GREBClimate.jl](https://github.com/EnvDroneSense/GREBClimate.jl), the GREB climate model. The model package stays stable; work that asks a question of the model, or that may change often, lives here.

This repository is a Julia package, `GREBExperiments`, plus scripts. The package holds helpers that reduce a model result to a few numbers; the scripts run the model and use them.

## Installation

Requires Julia 1.10 or later. The package is not registered; work from a clone:

```bash
git clone https://github.com/EnvDroneSense/GREBExperiments.git
cd GREBExperiments
julia --project=. -e 'using Pkg; Pkg.instantiate()'
```

`GREBClimate` is pinned to one minor version (`~2.3` in `Project.toml`). The helpers use some names the model package does not export, so a new model release can break them. Raise the pin only after the tests pass against the new release.

The scripts need the model's input dataset in a local copy and never download it; see the GREBClimate documentation.

## Where to go next

| Page | For |
|:-----|:----|
| [Running the scripts](@ref) | The two scripts, their arguments and what they print |
| [Reducing a run](@ref) | Turn a `greb_model!` result into annual global means and check it stayed in range |
| [Climate sensitivity](@ref) | The Gregory estimate of forcing, feedback and sensitivity |
| [Map diagnostics](@ref) | Area-weighted means, zonal means, polar amplification, land and ocean, pattern correlation |
| [Fitting a cycle](@ref) | Amplitude, lag and mean of a periodic response |
| [API Reference](@ref) | Every exported function |
