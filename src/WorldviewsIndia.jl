########################
# Basic setup
########################

# Run once upon initializing (this may change with update)
cd("src")

# Call necessary packages
using Mimi
using DataArrays, DataFrames, Plots, PyPlot, StatPlots, RCall

# For StatPlots; necessary due to DataFrames incompatibility
gr(size=(400,300))

###########################
# Begin model construction
###########################

#Load function to construct model
include("fund.jl")

#Create model for test run
INDIA-PRO = getfund()


###########################
# MITIGATION
###########################

# Because in emissions component,
# v.mitigationcost[t, r] = (p.taxmp[r] * v.ryg[t, r] + v.n2ocost[t, r]) * p.income[t, r]
# where for all regions p.taxmp = ~Gamma(5.8284;0.2071)
setparameter(INDIA-PRO,:emissions, :taxmp, zeros(1051,16))
# NB we choose not to employ p.income because it is calculated in the socioeconomic component and
# equivalent to p.gdp0 (baseline)
# NB also, if we choose one of the other two options, we can examine p.taxmp as an UNCERTAINTY

# Because in emissions component, v.emission[t, r] = (1 - v.scei[t - 1, r]) * v.emissint[t, r] * v.energuse[t, r]
# And also, v.emissionwithforestry[t, r] = v.emission[t, r] + p.forestemm[t, r]
setparameter(INDIA-PRO,:emissions, :forestemm, zeros(1051,16))
# NB we may choose to further manipulate this particular element by
# addressing v.emissint and/orv.energyuse

# Because in emissions component, v.mco2[t] = p.globco2
# And in climateco2cycle component, v.globc[t] = p.mco2[t] + v.TerrestrialCO2[t]
setparameter(INDIA-PRO,:emissions, :globco2, zeros(1051,16))

###########################
# ADAPTATION
###########################

# Because in sealevelrise component,
# v.protlev[t, r] = max(0.0, 1.0 - 0.5 * (v.npprotcost[t, r] + v.npwetcost[t, r]) / v.npdrycost[t, r])
# And v.npprotcost[t, r] = p.pc[r] * ds * (1.0 + p.slrprtp[r] + ypcgrowth) / (p.slrprtp[r] + ypcgrowth)
# Here, potential avenues include p.pc (via subsidies, R&D invest, etc), p.slrprpt, OR p.ypcgrowth
setparameter(INDIA-PRO,:impactsealevelrise, :pc, zeros(1051,16))
# OR, IF WANT UNCERTAINTY EXAMINED:
setparameter(INDIA-PRO,:impactsealevelrise, :slrprpt, zeros(1051,16))
# And because in sealevelrise component, v.imigrate[r1, r2] = p.migrate[r2, r1] / immsumm
setparameter(INDIA-PRO,:impactsealevelrise, :migrate, zeros(1051,16))

###########################
# TEMPERATURE
###########################

# Because in climateregional component, v.regstmp[t, r] = p.inputtemp[t] * p.bregstmp[r] + p.scentemp[t, r]
setparameter(INDIA-PRO,:climateregional, :inputtemp, zeros(1051,16))
# AND (possibly useful as an UNCERTAINTY)
setparameter(INDIA-PRO,:climateregional, :bregstmp, zeros(1051,16))
# AND
setparameter(INDIA-PRO,:climateregional, :scentemp, zeros(1051,16))

###########################
# VULNERABLITY
###########################

# Because in socioeconomic component,
# v.ygrowth[t, r] = (1 + 0.01 * p.pgrowth[t - 1, r]) * (1 + 0.01 * p.ypcgrowth[t - 1, r]) - 1
# treat all the following as UNCERTAINTIES
setparameter(INDIA-PRO,:socioeconomic, :pgrowth, zeros(1051,16))
# AND
setparameter(INDIA-PRO,:socioeconomic, :ypcgrowth, zeros(1051,16))

###########################
# Historical Responsibility
###########################

# Because in emissions component,
# v.co2red[t, r] = p.currtax[t, r] * v.emission[t, r] * v.know[t - 1, r] * v.globknow[t - 1] / 2 / v.taxpar[t, r] / p.income[t, r] / 1000
# Direct means of addressing might be via setting p.currtax
setparameter(INDIA-PRO,:emissions, :currtax, zeros(1051,16))
# Alternatively, indirect means of addressing might be adjusting code to create parameter that
# allows v.co2red to be a function of emissions in a given time/region
# This requires a different setup than the below, obviously bc right now co2red is a variable.
setparameter(INDIA-PRO,:emissions, :co2red, zeros(1051,16))
# NB in all cases this is only designed for pre-2010

###########################
# Future Responsibility
###########################

# See above; only difference from Historical is relevant dates (post 2010 vs pre 2010)

###########################
# Consumption
###########################

# Because in socioeconomic component,
# v.consumption[t, r] = v.income[t, r] * 1000000000.0 * (1.0 - p.savingsrate)
# We handle this as an UNCERTAINTY using p.savingsrate
setparameter(INDIA-PRO,:socioeconomic, :savingsrate, zeros(1051,16))

###########################
# Agriculture
###########################

# Because in the impactagriculture component,
# v.agrate[t, r] = p.agrbm[r] * (dtemp / 0.04)^p.agnl + (1.0 - 1.0 / p.agtime[r]) * v.agrate[t - 1, r]
# v.aglevel[t, r] = p.aglparl[r] * p.temp[t, r] + p.aglparq[r] * p.temp[t, r]^2.0
# v.agco2[t, r] = p.agcbm[r] / log(2.0) * log(p.acco2[t - 1] / p.co2pre)
# We largely handle this using the following UNCERTAINTIES:
# rate
setparameter(INDIA-PRO,:impactagriculture, :agrbm, zeros(1051,16))
setparameter(INDIA-PRO,:impactagriculture, :agnl, zeros(1051,16))
setparameter(INDIA-PRO,:impactagriculture, :agtime, zeros(1051,16))
# level
setparameter(INDIA-PRO,:impactagriculture, :aglparl, zeros(1051,16))
setparameter(INDIA-PRO,:impactagriculture, :aglparq, zeros(1051,16))
# fertilization
setparameter(INDIA-PRO,:impactagriculture, :agcbm, zeros(1051,16))

# Run
run(INDIA-PRO)

# Verify results; export and save values
results_INDIA-PRO = getdataframe(INDIA-PRO, :population, :populationin1)
writetable("C:\\Users\\Valeri\\Dropbox\\RAND\\Data\\Results\\xxxxxx.csv",results_INDIA-PRO)
results_INDIA-PRO_T = unstack(results_INDIA-PRO, :time, :regions, :populationin1)
writetable("C:\\Users\\Valeri\\Dropbox\\RAND\\Data\\Results\\XXXXXXX.csv", results_INDIA-PRO_T)
