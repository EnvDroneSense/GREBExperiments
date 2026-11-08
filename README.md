# GREBExperiments

Experiments on the [GREB climate model](https://github.com/EnvDroneSense/GREBClimate.jl): what happens to a simple, fast climate model when you push it in different ways, and the tools to measure it.

GREB runs a 96 x 48 grid with a 12-hour step; 100 simulated years take minutes, and several variants can run side by side. That suits questions that a full climate model is too slow to answer for a whole range of settings. The model package stays stable and lives in its own repository; this one holds the questions.

Documentation: <https://envdronesense.github.io/GREBExperiments/dev/> (published once the repository is public).

## What is here now

| Path | Holds |
|:-----|:------|
| `scripts/sensitivity.jl` | Effective climate sensitivity of an abrupt-CO2 preset, from the Gregory regression |
| `scripts/co2_sweep.jl` | The last-year climate over a range of CO2 levels, run side by side |
| `src/` | The Julia package `GREBExperiments`: helpers that reduce a run to a few numbers (annual means, Gregory estimate, map diagnostics, cycle fit) |
| `test/` | Tests of the helpers; they run without the dataset |
| `docs/` | The documentation site |

## Questions I want to explore

None of these needs a change to the model.

| Question | Approach |
|:---------|:---------|
| How much of the warming from doubled CO2 does each process carry (ice albedo, clouds, water vapour, ocean, heat transport)? | Switch one process at a time and compare with the full response |
| How does the response depend on the period of the forcing? | Force with CO2 or sunlight cycles from 1 to 200 years and fit the amplitude and lag |
| How far behind equilibrium is the climate when CO2 has doubled? | A 1 percent per year ramp, with and without the deep ocean |
| Does the climate come back along the same path when CO2 goes up and then down? | Ramp up and down and compare the two branches |
| Where does the ice-albedo feedback run away, and is there a second stable state? | Sweep the solar constant up and down |
| Do regional responses add up to the global one? | Force the tropics, the extratropics and the two hemispheres separately and sum |
| Does the pattern of warming depend on the forcing? | Compare CO2 and solar forcing at the same global forcing: polar amplification, land against ocean |
| Which matters more by 2100: the choice of scenario or the choice of rain scheme? | Cross the scenarios with the rain schemes as one ensemble |
| How uncertain is the response given uncertain parameters and inputs? | Perturb them in an ensemble and report the spread |
| Does the season of the forcing matter? Are the El Nino and La Nina responses mirror images? | Seasonal CO2 and the two composites |
| How close is a historical run to the observed warming? | Run the historical CO2 record and compare with an observed series |

Experiments that need a change to the model's physics belong in the model package, not here.

## Setup

Requires Julia 1.10 or later. The package is not registered:

```bash
git clone https://github.com/EnvDroneSense/GREBExperiments.git
cd GREBExperiments
julia --project=. -e 'using Pkg; Pkg.instantiate()'
```

GREBClimate is pinned to one minor version (`~2.3`), since the helpers use some names it does not export. Raise the pin only after the tests pass against the new release. To work against a local checkout of the model, run `Pkg.develop(path="../GREB-julia")`; `Manifest.toml` is not committed.

The scripts read the model's input dataset from a local copy and never download it; see the GREBClimate documentation.

## Run

```bash
julia --project=. -t 2,0 scripts/sensitivity.jl co2_double 100
julia --project=. -t 4,0 scripts/co2_sweep.jl 5 30
julia --project=. -e 'using Pkg; Pkg.test()'
```

Results go to `scripts/out/`, which git ignores. [CONTRIBUTING.md](CONTRIBUTING.md) explains how to add a script or a helper.

## Origin

The helpers and the first two scripts were moved here, with their history, from the `tools/experiments/` folder of GREBClimate.jl.

## License

MIT, see `LICENSE`.
