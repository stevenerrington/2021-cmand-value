###################################################################
#### Setup workspace
# Clear the workspace for the new analysis
rm(list=ls())

# Import relevant libraries
library(plyr)
library(rtdists)
library(ggplot2)

###################################################################
#### Import raw data into R from CSV
# Get a list of all the sessions within the data folder to analyses
sessionList = list.files(path = "_data/csv_raw",
                         pattern = "*.csv",
                         full.names = F)

# Load in the first session from the CSV file
i = sessionList[1]
dat = read.csv(paste("_data/csv_raw/", i, sep = ""),
               header = T,
               stringsAsFactors = FALSE)

###################################################################
#### Clean data
# Make trials that were not started with a NA
dat$response[dat$response == "NoStart"] <- NA
dat$response[dat$response == "NoResponse"] <- NA
dat$response[dat$trialType == "Stop"] <- NA
dat$rt[dat$rt > 1000] <- NA
dat$rt[dat$rt < 100 & dat$rt > 2] <- NA

# Remove the NA trials
dat <- na.omit(dat)


###################################################################
#### Define the optimization function
# State function and input arguments
objective_fun <- function(par, rt, response, distribution = "norm") {
  
  # simple parameters
  spar <- par[!grepl("[12]$", names(par))]  
  
  # distribution parameters:
  dist_par_names <- unique(sub("[12]$", "", grep("[12]$" ,names(par), value = TRUE)))
  dist_par <- vector("list", length = length(dist_par_names))
  names(dist_par) <- dist_par_names
  for (i in dist_par_names) dist_par[[i]] <- as.list(unname(par[grep(i, names(par))]))
  dist_par$sd_v <- c(1, dist_par$sd_v) # fix first SD to 1
  
  # get summed log-likelihood:
  d <- do.call(dLBA, args = c(rt=list(rt), response=list(response), spar, dist_par, 
                              distribution=distribution, silent=TRUE))

  if (any(d < 0e-10)) return(1e6) 
  else return(-sum(log(d)))
}

###################################################################
#### Run the optimized LBA function
# Specify input data
rt_data <- dat[, c('rt', 'value')]
rt_data$value[rt_data$value == "Low"] <- 1
rt_data$value[rt_data$value == "High"] <- 2

# Define initial parameters from which to search from
init_par <- runif(6)
init_par[2] <- sum(init_par[1:2]) # ensures b is larger than A
init_par[3] <- runif(1, 0, min(rt_data$rt)) #ensures t0 is mot too large
names(init_par) <- c("A", "b", "t0", "mean_v1", "mean_v2",  "sd_v2")

# Run the LBA optimization code
LBA_param = nlminb(objective_fun, start = init_par, rt=rt_data$rt, response=rt_data$value, lower = 0)


###################################################################
#### Generate simulated data
# Run the LBA simulation using the extracted parameters
LBA_rt <- rLBA(length(rt_data$rt), A=LBA_param$par["A"], b=LBA_param$par["b"], t0 = LBA_param$par["t0"],
            mean_v=c(LBA_param$par["mean_v1"], LBA_param$par["mean_v2"]), sd_v=c(1,LBA_param$par["sd_v2"]))

###################################################################
#### Plot Figure

# Define input data to plot
input_rt_data_obs_low <- rt_data$rt[rt_data$value == 1]
input_rt_data_lba_low <- LBA_rt[LBA_rt$response == 1,1]

input_rt_data_obs_high <- rt_data$rt[rt_data$value == 2]
input_rt_data_lba_high <- LBA_rt[LBA_rt$response == 2,1]

# Combine observed and LBA data
rt <- c(input_rt_data_obs_low, input_rt_data_lba_low,input_rt_data_obs_high,input_rt_data_lba_high)


obs_label <- c(rep("observed",length(input_rt_data_obs_low)),
               rep("LBA",length(input_rt_data_lba_low)),
               rep("observed",length(input_rt_data_obs_high)),
               rep("LBA",length(input_rt_data_lba_high)))

value_label <- c(rep("Low",length(input_rt_data_obs_low)),
                 rep("Low",length(input_rt_data_lba_low)),
                 rep("High",length(input_rt_data_obs_high)),
                 rep("High",length(input_rt_data_lba_high)))

combined_data <- data.frame(rt, obs_label, value_label)

# Generate plot in ggplot 
ggplot(combined_data, aes(x = rt, fill = obs_label)) + # Draw two histograms in same plot
  facet_wrap(~ value_label) + 
  geom_histogram(alpha = 0.5, position = "identity", binwidth = 25) +
  xlab("Response latency (ms)") + ylab("Frequency") +
  xlim(0, 700) +
  labs(fill = "Data")


###################################################################
#### Compare distributions
dist_comparison_ks = ks.test(input_rt_data_obs_low, input_rt_data_lba_low)
dist_comparison_ks = ks.test(input_rt_data_obs_high, input_rt_data_lba_high)


