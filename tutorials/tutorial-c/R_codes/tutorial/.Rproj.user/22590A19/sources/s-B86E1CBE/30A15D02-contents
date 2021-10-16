# Here, we begin to explore the delay discounting models in hBayesDM

# Exponential model
?dd_exp

# Hyperbolic model
?dd_hyperbolic

# Constant Sensitivity model (not used in example, but feel free to take a look!)
?dd_cs

# Are the data generated from the exponential or hyperbolic model? Is there 
# evidence of preference switching? 

# Fit the exponential model ---------------------------------------------------
fit_exp <- dd_exp("example", niter = 2000, nwarmup = 1000, 
                  nchain = 2, ncore = 2)

# Important!!! Always check for convergence before moving on
# Make sure the chains are "mixing" well ("furry caterpillars")
plot(fit_exp, type = "trace")

# Return a data.frame with all parameter names and Rhat values
rhat(fit_exp)

# To only check if Rhat values are under a specified criteria, 
# use the "less" argument
rhat(fit_exp, less = 1.1)

# Visualize posterior distributions in multiple ways
# Method 1 -- Group parameter histograms
plot(fit_exp)

# Method 2 -- Display individual parameters
plotInd(fit_exp, pars = "r")

# Method 3 -- Plot highest density intervals (HDI)
plotHDI(fit_exp$parVals$mu_r) 

# Fit the hyperbolic model ----------------------------------------------------
fit_hyp <- dd_hyperbolic("example", niter = 2000, nwarmup = 1000, 
                         nchain = 2, ncore = 2)

# Again, check for convergence
plot(fit_hyp, type = "trace")

# And for Rhat values 
rhat(fit_hyp, less = 1.1)

 
# Now, use LOOIC to compare model fits ----------------------------------------
printFit(fit_exp, fit_hyp)
# Hyperbolic model is closest to negative infinity, so it provides the best fit! 

# Now, we can make inference with the best-fitting model ----------------------
# Look at the posterior means for each subject/parameter
fit_hyp$allIndPars

# We can find out if discounting rate is related to impulsivity as measured by
# the Barratt Impulsiveness Scale (BIS)
# Read in BIS scores
bis_scores <- read.table(file.choose(), header = T, sep = "\t") 

# Run correlation test between discounting rate and BIS score
cor.test(fit_hyp$allIndPars$k, bis_scores$x)

# Variational bayes!
# Let's compare MCMC estimates and VB estimates
fit_hyp_vb <- dd_hyperbolic("example", niter = 2000, nwarmup = 1000, 
                         nchain = 2, ncore = 2, vb=TRUE)

# plot posterior means 
plot(fit_hyp$allIndPars$k, 
     fit_hyp_vb$allIndPars$k,
     xlab = "MCMC", ylab="VB")
# plot y=x line
abline(0,1)
