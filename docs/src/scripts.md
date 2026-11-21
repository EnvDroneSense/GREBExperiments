# Running the scripts

The scripts in `scripts/` run the model to answer a question. They read the local dataset with `greb_data_dir(; allow_download=false)` and never download it. Run each script from the repository root.

| Script | Question | Typical run time |
|:-------|:---------|:-----------------|
| `sensitivity.jl` | What is the effective climate sensitivity of an abrupt-CO2 preset? | Minutes for 100 years |
| `co2_sweep.jl` | How does the last-year climate change with the CO2 level? | Minutes for the default 5 levels of 30 years; hours for a full curve |

## The sensitivity script

```bash
julia --project=. -t 2,0 scripts/sensitivity.jl [preset] [scenario years] [spin-up years] [control years]
```

The defaults are `co2_double`, 100 scenario years, a spin-up of 3 years and a control of 2 years, on the NCEP climatology. The control repeats the same year, so more control years add nothing. The script gives the annual global means of the scenario to [`gregory`](@ref) (see [Climate sensitivity](@ref)). The preset must give its scenario as an anomaly. A short run:

```text
co2_double, 20 scenario years, spin-up 2, control 3
  forcing                   4.95 W/m2
  feedback                 -1.81 W/m2/K
  effective sensitivity     2.73 K
  r2                       0.999
  warming reached           2.50 K
  net flux remaining        0.39 W/m2
```

The lines are the fields of the [`gregory`](@ref) result. The 100-year default for `co2_double` gives 5.06 W/m2, -1.88 W/m2/K and 2.69 K, with 3.00 K reached.

## CO2 sweep

```bash
julia --project=. -t 4,0 scripts/co2_sweep.jl [levels] [scenario years] [spin-up years] [control years]
```

The script holds CO2 at `levels` values (default 5), log-spaced from 170 ppm (`:co2_half`) to 3400 ppm (`:co2_10x`), after a control at 280 ppm. It needs at least 12 scenario years, because it takes a last-year mean. It prints the anomaly of the last scenario year. Through [`run_members`](@ref), it also writes the rows to `scripts/out/co2_sweep.csv` (ignored by git) and a manifest to `co2_sweep_manifest.toml`. A short run:

```text
 CO2 [ppm]    Ts [K]       ice    precip
     170.0     -1.27    0.0113    -0.176
     760.0      2.95   -0.0228     0.484
    3400.0      8.22   -0.0492      1.66
```

| Column | Unit |
|:-------|:-----|
| `Ts` | K, global mean |
| `ice` | Fraction of the grid, global mean |
| `precip` | mm/day, global mean |

The levels run in parallel, so the script needs several threads. Each running level holds 370 MB of fields, so examine the free memory before you increase `-t`.

## The helpers

The scripts use the module `GREBExperiments` in `src/`. The helper pages and the [API Reference](@ref) describe its functions.
