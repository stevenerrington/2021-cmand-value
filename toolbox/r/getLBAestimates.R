set.seed(0)


getLBAestimates <- function (session_name,input_rt_data) 
{
  ###################################################################
  #### Define function for fitting
  # Setup function
  objective_fun <- function(par, rt) {
    # get summed log-likelihood:
    d <- do.call(dlba_norm, args = c(rt=list(rt), par, posdrift = TRUE, robust = FALSE))
    if (any(d < 0e-10)) return(1e6) 
    else return(-sum(log(d)))
  }
  
  ###################################################################
  #### Define data for input
  # Initial parameters for optimization
  init_par <- runif(5)
  init_par[2] <- sum(init_par[1],init_par[2]) # ensures b is larger than A
  init_par[3] <- runif(1, 0, min(input_rt_data)) #ensures t0 is mot too large
  names(init_par) <- c("A", "b", "t0", "mean_v", "sd_v")
  
  ###################################################################
  #### Run function
  LBA_param = nlminb(objective_fun, start = init_par, rt=input_rt_data, lower = 0)
  LBA_param = optim(init_par, objective_fun, rt=input_rt_data)
  

  return(LBA_param)
  
}