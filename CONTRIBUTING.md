# Contributing to GREBExperiments

This repository holds experiments on the GREB model and the helpers that analyse them. Bug reports, new experiments and documentation fixes are welcome. For a change that is larger than a fix, open an issue first to agree on the question and the approach.

## Getting set up

```bash
git clone https://github.com/EnvDroneSense/GREBExperiments.git
cd GREBExperiments
julia --project=. -e 'using Pkg; Pkg.instantiate()'
julia --project=. -e 'using Pkg; Pkg.test()'
```

The tests need no dataset. The scripts read a local copy of the GREBClimate input data and never download it.

## Layout

| Path | Holds |
|:-----|:------|
| `src/` | The package `GREBExperiments`, one flat module. `driver.jl` runs the model and `io.jl` writes files; the other files are pure helpers. `plots.jl` holds the plot stubs |
| `ext/` | The plot methods, loaded with Plots.jl |
| `scripts/` | Scripts that run the model and use the package. The output goes to `scripts/out/` (ignored by git) |
| `notebooks/` | The Pluto notebook for students |
| `test/` | One `test_x.jl` per `src/x.jl`; `support.jl` holds the fixtures |
| `docs/` | The Documenter site |

## Adding an experiment script

1. Put it in `scripts/`. Start with a comment block that gives the command line, the question it answers, the defaults, a typical run time and what it needs (dataset, threads, memory).
2. Take its settings from the command line with defaults, and read the dataset with `greb_data_dir(; allow_download=false)`.
3. Guard the entry point with `if abspath(PROGRAM_FILE) == @__FILE__`, so the file can be loaded without running it.
4. Reduce each run to a few numbers before the next one starts (`summarize`), and check `out_of_range` before averaging.
5. Write results under `scripts/out/`. Do not commit them; put a short run, with its settings, in the documentation page instead.
6. Add a row to the table and a section in `docs/src/scripts.md`.

## Adding or changing a helper

A helper goes in `src/` when two scripts need it or when it can be tested on its own.

1. Make it a pure function of its arguments where possible. Only `driver.jl` runs the model and only `io.jl` writes files.
2. Give it a docstring with a signature, what it returns and the units. The docstring is the source of truth. Export the name in the `export` line of its source file. The docs build fails on an exported name without a docstring.
3. Add a testset to the `test/test_x.jl` of its source file. The testset must fail when the function is wrong. Test with small synthetic input: a test must not need the dataset, because CI has none.
4. Add it to `docs/src/api.md`. On the helper page it belongs to, explain its use with an example that runs as a doctest, and link to the docstring with `@ref`.

## The model dependency

GREBClimate is pinned to one minor version (`~2.3` in `Project.toml` and `docs/Project.toml`). The helpers use four names that the model does not export (`GREBClimate.lat_grid`, `is_land`, `dxlat_grid`, `RangeCheck`), so a new model release can break them.

- Use exported names where they exist. Do not use more internal names: export the name in GREBClimate first.
- To move to a new model release, change both pins, run the tests and the docs build, and fix what breaks in the same pull request.

## Checks before a pull request

```bash
julia --project=. -e 'using Pkg; Pkg.test()'
julia --project=docs -e 'using Pkg; Pkg.develop(path="."); Pkg.instantiate()'
julia --project=docs docs/make.jl
```

CI also checks the formatting of `src`, `test`, `scripts` and `docs` with JuliaFormatter 2 and the settings in `.JuliaFormatter.toml`.

## Conventions

- Committed prose uses plain ASCII hyphens, not em-dashes.
- Keep the 96 x 48 grid, the 12-hour step and the 730 steps per year out of the code as literals; they come from GREBClimate.
- One concern per commit. Say in the message what changed and why.
