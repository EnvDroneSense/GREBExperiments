# GREBExperiments

Experiments and analysis tools built on [GREBClimate.jl](https://github.com/EnvDroneSense/GREBClimate.jl), the GREB climate model. The model package stays stable. Work that asks a question of the model, or that changes frequently, is in this repository.

This repository holds a Julia package, `GREBExperiments`, scripts and a Pluto notebook. The package runs sets of model members and reduces each result to a few numbers. The scripts and the notebook use the package to answer one question each.

## Two parts

| Part | For | Start with |
|:-----|:----|:-----------|
| Guide | Students: do experiments in the notebook and read the results. No code. | [Getting started](@ref) |
| Reference | Developers: the scripts, the helper functions, their checks and errors | [Running the scripts](@ref) |

## Guide

| Page | Content |
|:-----|:--------|
| [Getting started](@ref) | What you need, how to open the notebook, how to read it |
| [Experiments](@ref) | The groups of experiments and the question of each group |
| [Climate sensitivity](@ref) | Forcing, feedback and the Gregory plot |
| [Climate patterns](@ref) | Polar amplification, land and ocean, the response to a cycle |

## Reference

| Page | Content |
|:-----|:--------|
| [Running the scripts](@ref) | The two scripts, their arguments and what they print |
| [Reducing a run](@ref) | Reduce a `greb_model!` result to annual global means and check that it stayed in range |
| [Sensitivity estimate](@ref) | The Gregory fit and its limits |
| [Map diagnostics](@ref) | Area-weighted means, zonal means, polar amplification, land and ocean, pattern correlation |
| [Fitting a cycle](@ref) | Amplitude, lag and mean of a periodic response |
| [Experiment plots](@ref) | The two experiment plots and the notebook environment |
| [API Reference](@ref) | The docstring of each exported function |
| [Changelog](@ref) | The changes of each version |

## Installation

Requires Julia 1.10 or later. The package is not registered; work from a clone:

```bash
git clone https://github.com/EnvDroneSense/GREBExperiments.git
cd GREBExperiments
julia --project=. -e 'using Pkg; Pkg.instantiate()'
```

`GREBClimate` is pinned to one minor version (`~2.3` in `Project.toml`). The helpers use some names that the model package does not export, so a new model release can break them. Raise the pin only after the tests pass against the new release.

The scripts and the notebook need a local copy of the input dataset of the model and never download it. See [Input data](https://EnvDroneSense.github.io/GREBClimate.jl/stable/data/) in the GREBClimate documentation.
