###################################################################
#### Setup workspace
# Clear the workspace for the new analysis
rm(list = ls())

# Set a seed for reproducability (hopefully!)
set.seed(0)

# Load in relevant libraries
library(plyr)
library(rtdists)
library(ggplot2)
source('getLBAestimates.r') # Load estimation scripts

# Get a list of all the sessions within the session_data folder to analyses
sessionList = list.files(path = "_data/csv_raw",
                         pattern = "*.csv",
                         full.names = F)

# Initiate variables 
lbaOutput = list()


###################################################################
#### Run extraction of parameters across all sessions
# For each session
for (i in 1:length(sessionList)) {
  # Load in the relevant session
  session_name = sessionList[i]
  session_data = read.csv(paste("_data/csv_raw/", session_name, sep = ""),
                          header = T,
                          stringsAsFactors = FALSE)
 

  ###################################################################
  #### Tidy and isolate session_data of interest to input to the model
  
  # Remove the following trial types from the data
  session_data$response[session_data$response == "NoStart"] <- NA # trials that weren't started
  session_data$response[session_data$response == "NoResponse"] <- NA # trials that didn't elicit a response
  session_data$response[session_data$trialType == "Stop"] <- NA # trials in which a stop-signal was presented
  session_data$rt[session_data$rt > 1000] <- NA # trials with too long RT's
  session_data$rt[session_data$rt < 100 & session_data$rt > 2] <- NA # trials with too short RT's
  
  session_data <- na.omit(session_data) # Remove trials.
  
  # Define the RT's of interest to fit to the accumulator
  input_rt_data <- session_data$rt[session_data$value == "Low"]
  
  ###################################################################
  #### Run LBA fitting function
  test = getLBAestimates(session_name,input_rt_data) # Run the estimation script
   
}



