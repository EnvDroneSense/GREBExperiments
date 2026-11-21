# Getting started

The notebook `notebooks/climate_experiments.jl` is the start point for students. You select an experiment and the run length. The notebook runs the model, checks the result and shows the plots. You do not write code.

## What you need

| Item | Where |
|:-----|:------|
| Julia 1.10 or later | [julialang.org](https://julialang.org/downloads/) |
| This repository | `git clone https://github.com/EnvDroneSense/GREBExperiments.git` |
| GREBClimate.jl, in a folder next to this repository | `git clone https://github.com/EnvDroneSense/GREBClimate.jl.git GREB-julia` |
| The input dataset of the model | See [Input data](https://EnvDroneSense.github.io/GREBClimate.jl/stable/data/) in the GREBClimate documentation. The notebook never downloads it. |

## Open the notebook

Run these two commands from the root of this repository. The first command sets up the notebook environment once.

```bash
julia notebooks/setup.jl
julia --project=notebooks -e 'using Pluto; Pluto.run(notebook="notebooks/climate_experiments.jl")'
```

Pluto opens the notebook in your web browser.

## Do an experiment

1. Select an experiment. [Experiments](@ref) tells what each experiment asks.
2. Set the control years and the scenario years.
3. Tick *Run the model*. A run of 30 years takes some minutes.
4. Read the result from the top of the notebook to the bottom.

| Part of the notebook | What it shows |
|:---------------------|:--------------|
| Did the run stay sensible? | `out_of_range` is `(ctrl = nothing, scnr = nothing)` when all values stayed in range. Do not use a run with a different value. The second number is the change of the global-mean surface temperature in the last year [K]. |
| How sensitive is the climate? | The Gregory plot. [Climate sensitivity](@ref) explains it. |
| Where does it warm? | A map of the surface temperature change and the time series of the global means. [Climate patterns](@ref) explains what to look for. |

When you change an experiment or a slider with *Run the model* ticked, the notebook runs the model again.
