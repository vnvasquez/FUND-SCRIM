[![Build Status](https://travis-ci.org/davidanthoff/fund.jl.svg?branch=master)](https://travis-ci.org/davidanthoff/fund.jl)

# FUND-SCRIM

This iteration of FUND in Julia has been cloned for the purpose of implementing a Sustainable Climate Risk Management (SCRIM) linkage project. It will establish a systematic approach to plural rationalities that uses FUND and Rhodium - a multi-objective robust decision-making tool - to generate a series of plausible policy scenarios with pareto satisfycing surfaces.

Please note: All text featured below has been included from the original repository for explanatory purposes.

## Requirements

The minimum requirement to run FUND is [Julia](http://julialang.org/) and the [Mimi](https://github.com/davidanthoff/Mimi.jl) package. To run the example IJulia notebook file you need to install [IJulia](https://github.com/JuliaLang/IJulia.jl).

### Installing Julia

You can download Julia from [http://julialang.org/downloads/](http://julialang.org/downloads/). You should use the v0.5.x version and install it.

### Installing the Mimi package

Start Julia and enter the following command on the Julia prompt:

````jl
Pkg.add("Mimi")
````

### Keeping requirements up-to-date (optional)

Many of these requirements are regularily updated. To make sure you have the latest versions, periodically execute the following command on the Julia prompt:

````jl
Pkg.update()
```
