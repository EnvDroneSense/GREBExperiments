# Climate patterns

The global mean is one number. The map shows where the climate changes. This page tells what to look for on the map and in the time series. [Map diagnostics](@ref) and [Fitting a cycle](@ref) give the code.

## Polar amplification

In most warming experiments, the regions near the poles warm more than the global mean. One cause is the sea ice and snow: when they melt, the dark surface below absorbs more sunlight. The polar amplification is the polar warming divided by the global warming. A value above 1 shows a stronger warming near the poles.

Look at the map of `co2_double`. Then compare the Arctic and the Antarctic: is the amplification the same in the north and the south?

## Land and ocean

Land usually warms more than ocean. The ocean stores more heat, and more water evaporates from it, which removes heat from the surface. Look at the map of `co2_double` and compare the continents with the oceans at the same latitude.

## Same forcing, different pattern

Two experiments can give a similar global warming but a different map. Compare `co2_double` with `solar_plus27`. More CO2 acts on the whole Earth by day and by night. More sunlight acts most where the sun is strongest. The pattern correlation measures how similar two maps are: 1 is the same pattern, 0 is no relation.

## Response to a cycle

When the forcing goes up and down, as in `co2_sine_wave` or `solar_cycle_11yr`, the temperature follows with a delay. The response is also smaller than the response to a constant forcing of the same size, because the ocean has no time to warm fully. A slow cycle gives a larger response and a longer delay than a fast cycle. On the time series, measure the delay between the peak of the forcing and the peak of the temperature.

## Questions to try

- Is the Arctic warming of `co2_quadruple` two times that of `co2_double`?
- In `regional_co2_nh`, how much does the Southern Hemisphere warm?
- After the CO2 decrease in `co2_abrupt_reverse`, how many years does the climate need to go back?
