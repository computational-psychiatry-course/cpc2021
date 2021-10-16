# First, read in data from Sokol-Hessner (2009)
# The "system.file" command can be used to locate the data in hBayesDM

# These are data collected when subjects were asked to attend to each trial
path_to_attend_data <- system.file("extdata/ra_data_attend.txt", package="hBayesDM")
# These are data collected when subjects were asked to view their choice as one
# within a large portfolio (i.e. think like a stock trader!)
path_to_regulate_data <- system.file("extdata/ra_data_reappraisal.txt", package="hBayesDM")

# We can now fit the models to each dataset and then compare parameters!

# Fit the full risk aversion model to "attend" and "regulate" data (i.e. prospect theory)
fit_att_1 <- ra_prospect(path_to_attend_data, niter = 2000, nwarmup = 1000, 
                         nchain = 2, ncore = 2, inits = "fixed")
fit_reg_1 <- ra_prospect(path_to_regulate_data, niter = 2000, nwarmup = 1000, 
                         nchain = 2, ncore = 2, inits = "fixed")
 
# Check convergence for both models
plot(fit_att_1, "trace"); rhat(fit_att_1, 1.1)
plot(fit_reg_1, "trace"); rhat(fit_reg_1, 1.1)

# Now, we can compare posterior distributions of parameters across conditions
# The "plotHDI" function is good for this
plotHDI(fit_att_1$parVals$mu_rho - fit_reg_1$parVals$mu_rho)
plotHDI(fit_att_1$parVals$mu_lambda - fit_reg_1$parVals$mu_lambda)
plotHDI(fit_att_1$parVals$mu_tau - fit_reg_1$parVals$mu_tau)
 
# How much of the difference in probability mass is above 0? (~0.5 if no difference)
mean((fit_att_1$parVals$mu_rho - fit_reg_1$parVals$mu_rho)>0)
mean((fit_att_1$parVals$mu_lambda - fit_reg_1$parVals$mu_lambda)>0)
mean((fit_att_1$parVals$mu_tau - fit_reg_1$parVals$mu_tau)>0)
 
