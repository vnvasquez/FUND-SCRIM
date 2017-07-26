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

# Set parameters to represent environmentalist Indian perspective
setparameter(INDIA-PRO,:impactdeathmorbidity,:cardheat, zeros(1051,16))
setparameter(INDIA-PRO,:impactdeathmorbidity,:cardcold, zeros(1051,16))
setparameter(INDIA-PRO,:impactdeathmorbidity,:resp, zeros(1051,16))

# Run
run(INDIA-PRO)

# Verify results; export and save values
results_INDIA-PRO = getdataframe(INDIA-PRO, :population, :populationin1)
writetable("C:\\Users\\Valeri\\Dropbox\\RAND\\Data\\Results\\xxxxxx.csv",results_INDIA-PRO)
results_INDIA-PRO_T = unstack(results_INDIA-PRO, :time, :regions, :populationin1)
writetable("C:\\Users\\Valeri\\Dropbox\\RAND\\Data\\Results\\XXXXXXX.csv", results_INDIA-PRO_T)
