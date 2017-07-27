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

# Because (emissions component):
### v.mitigationcost[t, r] = (p.taxmp[r] * v.ryg[t, r] + v.n2ocost[t, r]) * p.income[t, r]
### where for all regions p.taxmp = ~Gamma(5.8284;0.2071)
setparameter(INDIA-PRO,:emissions, :taxmp, zeros(1051,16))
### v.emission[t, r] = (1 - v.scei[t - 1, r]) * v.emissint[t, r] * v.energuse[t, r]
### v.emissionwithforestry[t, r] = v.emission[t, r] + p.forestemm[t, r]

# And because (climateco2cycle component):
### v.globc[t] = p.mco2[t] + v.TerrestrialCO2[t]
### where v.mco2[t] = globco2 from emissions component 
setparameter(INDIA-PRO,:climateco2cycle, :mco2, zeros(1051,16))

# Run
run(INDIA-PRO)

# Verify results; export and save values
results_INDIA-PRO = getdataframe(INDIA-PRO, :population, :populationin1)
writetable("C:\\Users\\Valeri\\Dropbox\\RAND\\Data\\Results\\xxxxxx.csv",results_INDIA-PRO)
results_INDIA-PRO_T = unstack(results_INDIA-PRO, :time, :regions, :populationin1)
writetable("C:\\Users\\Valeri\\Dropbox\\RAND\\Data\\Results\\XXXXXXX.csv", results_INDIA-PRO_T)
