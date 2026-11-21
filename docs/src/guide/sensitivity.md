# Climate sensitivity

The climate sensitivity tells how much the Earth warms when the CO2 level doubles. The notebook estimates it from one run with the Gregory method. [Sensitivity estimate](@ref) gives the code.

## Forcing and feedback

More CO2 makes the atmosphere absorb more of the heat that the surface emits. At first, the Earth emits less energy to space than it receives from the sun. This difference is the forcing ``F`` [W/m2].

The surface then warms, and a warmer surface emits more energy. Other processes add to the change: for example, less sea ice reflects less sunlight. The sum of these effects is the feedback ``\lambda`` [W/m2 per K]. It is negative for a stable climate, because the warming decreases the imbalance.

The net flux ``N`` at the top of the atmosphere follows, to first order:

```math
N = F + \lambda \, \Delta T
```

The warming stops when ``N`` is zero. Then ``\Delta T = -F / \lambda``. This is the sensitivity.

## Reading the Gregory plot

| Part of the plot | Meaning |
|:-----------------|:--------|
| A dot | One year of the run: its warming and its net flux |
| The line | The fit of the dots |
| Where the line meets the vertical axis | The forcing ``F`` |
| The slope of the line | The feedback ``\lambda`` |
| The star, where the line meets zero net flux | The effective sensitivity |

The first years are at the top left: little warming and a large imbalance. The dots then move down and to the right. In a long run the dots come near to the star, but they do not reach it in a few decades, because the ocean warms slowly.

For `co2_double`, the model gives a forcing of about 5 W/m2, a feedback of about -1.9 W/m2 per K and a sensitivity of about 2.7 K. The 2021 IPCC report gives a likely range of 2.5 to 4 K for the real Earth.

## Questions to try

- Does `co2_quadruple` give two times the forcing of `co2_double`? Does it give the same sensitivity?
- Do the dots stay on a straight line? A curve shows that the feedback changes with the warming.
- How does the estimate change when you use 15 scenario years in place of 60?
