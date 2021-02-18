
## ---- LIBRARIES -------------------------------------------------------------

require("parallel")
require("doParallel")
require("foreach")


## ---- PRELIMINARIES ---------------------------------------------------------

simulation_name <- "name_yyyy_mm_dd"

cores <- 4
cl <- parallel::makeCluster(cores)
doParallel::registerDoParallel(cl, cores = cores)


## ---- PARAMETERS ------------------------------------------------------------

# all combinations of the model parameters will be run
model_parameters <- list(
d1 = 5,
d2 = 6,
p1 = 20,
p2 = 25,
n = 2000,
sds = seq(from = 0.2,
          to = 3,
          length.out = 20),
data_dists = c("norm", "t"),
err_dists = c("norm", "t"),
method = c("orth bs", "asymp no norm")
)

m <- 1000 # number of simulations for each setup

# number of total iterations before the current state is stored.
save_iterations <- cores*100

## ---- PARAMETER CHECKS ------------------------------------------------------

# how the grid without result would look like in one iteration
print(expand.grid(model_parameters))

## creating data frame for results
res_grid <- expand.grid(c(model_parameters, list(run = 1:m, res = -1)))


## ---- SIMULATION ------------------------------------------------------------

# the following two commands group indeces from one to the length of the df
# into groups of the size of save_iterations. The last one may be smaller
# depending if the nrow(res_grid) was not a multiple of save_iterations
split_indices <- ceiling((1:nrow(res_grid)) / save_iterations)
index_groups <- split(1:nrow(res_grid), split_indices)

# the outer loop runs through the groups of indeces.
# the inner loop through each part of the dataframe in parallel
# at the end of each iteration of the outer loop, the data is saved
for(i in 1:length(index_groups)){
  ret <- foreach(it=iter(res_grid[index_groups[[i]],], by='row'), .combine = c) %do%{
    1 # add function that takes it as input and returns a single numeric value
  }
  res_grid[index_groups[[i]],"res"] <- ret
  saveRDS(resgrid, file=paste0("results/", simulation_name))
}
