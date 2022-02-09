### Code written by Patrick Skippen (patrick.skippen@uon.edu.au) for analysis of
### Ageility project (Karayanidis et al., 2016) We take the output from the EEG
### timings and process based on behavioural performance and compliance of
### participants

#### Set-up workspace ####
source("Code/Functions/parse/aux_pars.R") # See select_subj() below; From Dora Matzke (d.matzke@uva.nl)
library(plyr)

##### Takes the raw behavioural data and screens for poor performance
Filenames = list.files(path = "Behav_Data/",
                       pattern = "*.csv",
                       full.names = F)

#### Load all participants for cleaning ####
subj = Filenames
i = subj[1]
dat = read.csv(paste("Behav_Data/", i, sep = ""),
               header = T,
               stringsAsFactors = FALSE)[, c(
                 "subject",
                 'trial',
                 "block",
                 "blocktrial",
                 "target",
                 "correctresponse",
                 "staircase",
                 "ssdelay",
                 "response",
                 "accuracy",
                 "ssaccuracy",
                 "rt"
               )]

for (i in subj[-1]) {
  dat <- rbind(dat,
               read.csv(paste("Behav_Data/", i, sep = ""), header = T)[, c(
                 "subject",
                 'trial',
                 "block",
                 "blocktrial",
                 "target",
                 "correctresponse",
                 "staircase",
                 "ssdelay",
                 "response",
                 "accuracy",
                 "ssaccuracy",
                 "rt"
               )])
}

### General performance deficits that need to be addressed ####
# Some px had no responding in an entire block. Only one of these px's noted to the experimentor that they did so intentially - although this was not a specific QN asked by the experimentor
# As such, we cannot be sure that this responding in other participants is not intentional. However, if it was true 'failure' the EXG3 model would pick up these trials as it does not read trial/block numbers
# We decided to removed 6 blocks across 6 participants who did not respond at all during an entire block; for one PX this was only on the Rigth button presses; all others were across hands.

## AGE073 - No Right button pressing on the 5th block
table(dat$response[dat$block == 5 & dat$subject == "AGE073"])
dat$response[dat$block == 5 & dat$subject == "AGE073"] <- NA

## AGE107 - No Stop Success in 1st block
table(dat$ssaccuracy[dat$block == 1 & dat$subject == "AGE107"])
dat$response[dat$block == 1 & dat$subject == "AGE107"] <- NA

## AGE172 - Remove block 1 from participant AGE172 as they noted to have "not interpreted task for first block"
dat[dat$block == 1 & dat$subject == "AGE172",] <- NA

## AGE176 - No responding in 2nd block
table(dat$ssaccuracy[dat$block == 2 & dat$subject == "AGE176"])
dat$response[dat$block == 2 & dat$subject == "AGE176"] <- NA

## AGE246 - No responding in 4th block
table(dat$ssaccuracy[dat$block == 4 & dat$subject == "AGE246"])
dat$response[dat$block == 4 & dat$subject == "AGE246"] <- NA

## AGE275 - No responding in 1st block
table(dat$ssaccuracy[dat$block == 1 & dat$subject == "AGE275"])
dat$response[dat$block == 1 & dat$subject == "AGE275"] <- NA

check <- length(dat[, 1])
dat <- na.omit(dat) # shoud drop ~ 6*140 = 840 trials
check - length(dat[, 1])

# Remove cases with SSD > 845 (largest increment SSD; 845ms with the above change) ##
hist(dat$ssdelay[dat$ssdelay > 0],
     breaks = 50,
     xlab = "Stop Signal Delay (ms)",
     main = "Histogram of Stop Signal Delay across sample")
dat <- dat[dat$ssdelay <= 845,] # - loss of 12 trials

# # remove greater than 4.8s (greatest ITI)
tail(sort(dat$rt[dat$target != "Stop"]), 50)
dat <- dat[dat$rt < 4800,] # - one single trial

# ------------------------------------------------------------------------------------------------------------------- #
#### Below are the exclusion criteria used within the article
#### Can be done manually if necessary as the resulting 'checks' data frame inside the idx list
#### has all the summary data.

# Set exclusion criteria:
my_omission = 1		# No Go omission exlusion necessary, i.e., 100%
my_error_lnr = 0.45		# Exclude participants with extremely high error rate (too high even for lognormal race, e.g., 45%)
my_error_beests = 0.15	#exclude participants with error rate that is too high for BEESTS, e.g., 10%
my_RR = c(0, 0.75)
my_short_RR = 1	# Exlude participants with high response rate on shortes delay; extreme trigger failure rate so no info for parameter estimation OR non-compliance?
my_slowing = c(-300, 300) # Exclude Px with slowing of RT across the trials of >300ms

# this function returns the subject IDs of subjects who
#	- are eligible for inclusion based on above criteria
# 	- don't violate context independence: mean go > mean SRRT
#     - have valid go RTs
# also plots some info about min and max RTs, response rates, etc., in jpg format) - found in "Aux_pars_OUTPUT"

# call for controls (just ignore the warnings):
idx = select_subj(
  filenames = Filenames,
  path = paste(getwd(), "/Behav_Data/", sep = ""),
  my_omission = my_omission,
  my_error_lnr = my_error_lnr,
  my_error_beests = my_error_beests,
  my_RR = my_RR,
  my_short_RR = my_short_RR,
  my_slowing = my_slowing
)

idx$original_N           # 207
length(idx$subj_beests) # 169
length(idx$subj_lnr)     # 178
idx$subj_lnr

# Checks:
sum(!idx$checks$include_error_lnr) #1
idx$checks$subj_idx[!idx$checks$include_error_lnr]
# [1] "AGE143"
sum(!idx$checks$include_RR_lnr)    #5
idx$checks$subj_idx[!idx$checks$include_RR_lnr]
# [1] "AGE181" "AGE236" "AGE239" "AGE269" "AGE272"
sum(!idx$checks$independence)      #17
idx$checks$subj_idx[!idx$checks$independence]
# "AGE042" "AGE053" "AGE070" "AGE107" "AGE143" "AGE156" "AGE163"
# "AGE166" "AGE167" "AGE169" "AGE181" "AGE187" "AGE245"
# "AGE262" "AGE263" "AGE276" "AGE279"
sum(!idx$checks$include_slowing)   #8
idx$checks$subj_idx[!idx$checks$include_slowing]
# [1] "AGE013" "AGE034" "AGE111" "AGE119" "AGE199" "AGE228" "AGE247" "AGE248"

# In total we lose 29 Participants
DroppedPX <-
  c(
    idx$checks$subj_idx[!idx$checks$include_error_lnr],
    idx$checks$subj_idx[!idx$checks$include_RR_lnr],
    idx$checks$subj_idx[!idx$checks$independence],
    idx$checks$subj_idx[!idx$checks$include_slowing]
  )

length(unique(DroppedPX))
# 29
unique(DroppedPX)
# [1] "AGE143" "AGE181" "AGE236" "AGE239" "AGE269" "AGE272" "AGE042" "AGE053" "AGE070" "AGE107" "AGE156" "AGE163"
# [13] "AGE166" "AGE167" "AGE169" "AGE187" "AGE245" "AGE262" "AGE263" "AGE276" "AGE279" "AGE013" "AGE034" "AGE111"
# [25] "AGE119" "AGE199" "AGE228" "AGE247" "AGE248"

#### Remove Dropped Participants ####

# keep only suitable subjects #
check <- length(dat[, 1])
# nrow of dat drops by 20148; or ~700*29
dat <- dat[which(dat$subject %in% idx$subj_lnr),]

check - length(dat[, 1])

#### Model constraint screening ####

# Remove the participants with poor inhibition functions and speeding of RT over increasing SSDs;
# see folder "Aux_pars_OUTPUT"
dat <- dat[!(dat$subject %in% c("AGE179", "AGE120", "AGE149")),]
dat$subject <- factor(as.character(dat$subject))

# This subject never makes a go error - will not be able to fit mismatch parameter
dat <- dat[!(dat$subject %in% c("AGE079")),]
dat$subject <- factor(as.character(dat$subject))

#### Save off model data ####

length(levels(dat$subject)) #174, 15.9% censor rate.

save(dat, file = "DataForModelling/Clean_Data.RData")

### Summary of participant behavioural data ####

PxSumm <- idx$checks[idx$checks$subj_idx %in% levels(dat$subject),]
write.csv(PxSumm, file = "Output/BehaviouralSumm.csv", row.names = F)
