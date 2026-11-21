# Changelog

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
The project uses [Semantic Versioning](https://semver.org/). No version is tagged yet.

## [Unreleased]

### Added

- `run_members(reduce, run, configs; labels, outdir, name)`: runs the members
  through `run_ensemble` and returns one row per member. With `outdir`, it
  writes `<name>.csv` and `<name>_manifest.toml` (package versions, run
  lengths, columns, the configuration of each member, the time).
- `co2_file(path, years, values)`: writes a `year ppm` file for `CO2File`.
- `plot_response` and `plot_gregory` as a Plots.jl package extension
  (`ext/`). Plots.jl is a weak dependency. Without it, the stubs throw a
  `MethodError` with a hint.
- Pluto notebook `notebooks/climate_experiments.jl` for students, with
  `notebooks/setup.jl`.
- `gregory`: field `closure` (reached / sensitivity).
- `annual_means`: keyword `month_weights`.
- `summarize`: field `drift` of the control `Ts`.
- `in_range_report`: keyword `anomaly_limits`, a limit per field.
- `polar_amplification`: also returns the two polar means and the global mean.
- Dependencies: the standard libraries `Dates` and `TOML`.
- `CHANGELOG.md`, also shown as a docs page.
- Docs: a Guide for students (Getting started, Experiments, Climate sensitivity,
  Climate patterns) apart from the Reference for developers.

### Changed

- Breaking: `annual_means` returns `(years, values, dropped)`.
- Breaking: the `co2_sweep.jl` CSV columns are `co2_ppm`, `control_co2_ppm`,
  `Ts_anom_K`, `ice_anom_frac`, `precip_anom` and `out_of_range`.
- `in_range_report` tests anomalies against a limit per field (80 K for `Ts`
  and `Ta`, 40 K for `To`, 0.08 kg/kg for `q`). Before, a run that diverged by
  100 K passed.
- `co2_sweep.jl` uses `run_members`, states the control CO2 and flags a member
  that leaves the range.
- `sensitivity.jl`: the default control is 2 years.
- `src/helpers.jl` is split by data type into `common.jl`, `maps.jl`,
  `series.jl`, `reducing.jl`, `io.jl` and `driver.jl`. The names do not change.
  One test file per source file.
- Docstrings, comments and docs prose are in Simplified Technical English.
  The docs page `cycles.md` is now `series.md`.

### Fixed

- `gregory` throws for a constant `dTs` and returns `NaN` with a warning for a
  feedback >= 0.
- `annual_means` throws when a `(year, month)` occurs twice.
- `area_mean` (mask) and `zonal_mean` throw `DimensionMismatch` for a wrong
  size. `pattern_correlation` throws `ArgumentError` for a constant map.
- `sine_fit` throws for a series shorter than one period.
- Notebook: the last-year `Ts` change of an anomaly scenario no longer
  subtracts the absolute control temperature.
- Stale docs text: the scripts are in `scripts/`, and the tests no longer use
  `split_winds!`.

## [0.1.0] - 2026-11-08

### Added

- First version, extracted from `tools/experiments` in GREBClimate.jl: the
  helpers (`area_mean`, `zonal_mean`, `polar_amplification`, `land_ocean`,
  `pattern_correlation`, `annual_means`, `sine_fit`, `gregory`,
  `in_range_report`, `summarize`), the scripts `sensitivity.jl` and
  `co2_sweep.jl`, the tests, the Documenter site, CI, README and CONTRIBUTING.
