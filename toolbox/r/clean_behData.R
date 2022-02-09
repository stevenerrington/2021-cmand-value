# Clear the workspace for the new analysis
rm(list=ls())

# Setup workspace
source("./_toolbox/OSF_Skippen/parse/aux_pars.R") # See select_subj() below; From Dora Matzke (d.matzke@uva.nl)
library(plyr)

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
               stringsAsFactors = FALSE)[, c(
                 "sessionName",
                 'monkeyName',
                 "sessionN",
                 "trial",
                 "block",
                 "blocktrial",
                 "trialType",
                 "targetLoc",
                 "ssd",
                 "response",
                 "rt",
                 "value"
               )]


for (i in sessionList[-1]) {
  dat <- rbind(dat,
               read.csv(paste("_data/csv_raw/", i, sep = ""), header = T)[, c(
                 "sessionName",
                 'monkeyName',
                 "sessionN",
                 "trial",
                 "block",
                 "blocktrial",
                 "trialType",
                 "targetLoc",
                 "ssd",
                 "response",
                 "rt",
                 "value"
               )])
}


###################################################################
#### Clean data

# Make trials that were not started with a NA
dat$response[dat$response == "NoStart"] <- NA
dat$rt[dat$rt > 1000] <- NA
dat$rt[dat$rt < 100 & dat$rt > 2] <- NA

# Remove the NA trials
dat <- na.omit(dat)


# !!! at this stage we will need to do some more cleaning (aux_pars.R file)

#####################################################################
#### Save cleaned data output in RData format
save(dat, file = "./_data/2021_dajo_cleanData.RData")




