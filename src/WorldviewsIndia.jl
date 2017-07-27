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

# Run
run(INDIA-PRO)

# Verify results; export and save values
results_INDIA-PRO = getdataframe(INDIA-PRO, :population, :populationin1)
writetable("C:\\Users\\Valeri\\Dropbox\\RAND\\Data\\Results\\xxxxxx.csv",results_INDIA-PRO)
results_INDIA-PRO_T = unstack(results_INDIA-PRO, :time, :regions, :populationin1)
writetable("C:\\Users\\Valeri\\Dropbox\\RAND\\Data\\Results\\XXXXXXX.csv", results_INDIA-PRO_T)
