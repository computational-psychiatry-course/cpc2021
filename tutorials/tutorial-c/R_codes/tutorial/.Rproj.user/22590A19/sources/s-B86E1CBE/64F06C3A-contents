## Checking if Stan works before progressing

# Load rstan library
library(rstan)

# Find the example here: https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started#example-1-eight-schools
# We will only run this to see if Stan works, so understanding the code below
# is not important right now.
 
# Stan model
m1 <- "data {
  int<lower=0> J; 
  real y[J]; 
  real<lower=0> sigma[J]; 
}
parameters {
  real mu; 
  real<lower=0> tau;
  real eta[J];
}
transformed parameters {
  real theta[J];
  for (j in 1:J)
    theta[j] = mu + tau * eta[j];
} 
model {
  target += normal_lpdf(eta | 0, 1);
  target += normal_lpdf(y | theta, sigma);
}"

# Data to be fit 
schools_dat <- list(J = 8, 
                    y = c(28,  8, -3,  7, -1,  1, 18, 12),
                    sigma = c(15, 10, 16, 11,  9, 11, 10, 18))

# Fit model using 1000 iterations on 2 different chains (not parallel)
# Note that the model compiles at the beginning, so it takes time to start
fit1 <- stan(model_code = m1, data = schools_dat, 
             iter = 1000, chains = 2)
# visualize the output
plot(fit1)

# Same fit as above, but test parallel computing
#fit2 <- stan(model_code = m1, data = schools_dat, 
#             iter = 1000, chains = 2, cores = 2)
