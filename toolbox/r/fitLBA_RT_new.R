# Clear the workspace for the new analysis
  rm(list=ls())

# Setup workspace
source("./_toolbox/OSF_Skippen/parse/aux_pars.R") # See select_subj() below; From Dora Matzke (d.matzke@uva.nl)
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

dat$response[dat$response == "Left"] <- 1
dat$response[dat$response == "Right"] <- 2


# Remove the NA trials
dat <- na.omit(dat)


###################################################################
# Here, I will just extract RT data from go right/left trials
rt_data <- dat[, c('rt', 'response')]


# Setup function
objective_fun <- function(par, rt, response, distribution = "norm") {
  # simple parameters
  spar <- par[!grepl("[12]$", names(par))]  
  
  # distribution parameters:
  dist_par_names <- unique(sub("[12]$", "", grep("[12]$" ,names(par), value = TRUE)))
  dist_par <- vector("list", length = length(dist_par_names))
  names(dist_par) <- dist_par_names
  for (i in dist_par_names) dist_par[[i]] <- as.list(unname(par[grep(i, names(par))]))
  dist_par$sd_v <- c(1, dist_par$sd_v) # fix first sd to 1
  
  # get summed log-likelihood:
  d <- do.call(dLBA, args = c(rt=list(rt), response=list(response), spar, dist_par, 
                              distribution=distribution, silent=TRUE))
  if (any(d < 0e-10)) return(1e6) 
  else return(-sum(log(d)))
}

# Run function
init_par <- runif(6)
init_par[2] <- sum(init_par[1:2]) # ensures b is larger than A
init_par[3] <- runif(1, 0, min(rt_data$rt)) #ensures t0 is mot too large
names(init_par) <- c("A", "b", "t0", "mean_v1", "mean_v2",  "sd_v2")
LBA_param = nlminb(objective_fun, start = init_par, rt=rt_data$rt, response=rt_data$response, lower = 0)

LBA_rt <- rLBA(length(rt_data$rt), A=LBA_param$par["A"], b=LBA_param$par["b"], t0 = LBA_param$par["t0"],
            mean_v=c(LBA_param$par["mean_v1"], LBA_param$par["mean_v2"]), sd_v=c(1,LBA_param$par["sd_v2"]))

input_rt_data <- rt_data$rt


###################################################################
#### Plot Figure
# Combine observed and LBA data
rt <- c(input_rt_data, LBA_rt[,1])
label <- c(rep("observed",length(input_rt_data)),rep("LBA",length(LBA_rt[,1])))
combined_data <- data.frame(rt, label)

# Generate plot in ggplot 
ggplot(combined_data, aes(x = rt, fill = label)) + # Draw two histograms in same plot
  geom_histogram(alpha = 0.5, position = "identity", binwidth = 25) +
  xlab("Response latency (ms)") + ylab("Frequency") +
  labs(fill = "Data")


###################################################################
#### Compare distributions
dist_comparison_ks = ks.test(input_rt_data, LBA_rt[,1])


