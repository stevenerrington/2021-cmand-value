rm(list=ls())

#  setwd("D:/Dropbox/My Documents/LBA/WTF_Sz_results/Ageility_SS_BehaviouralData/Ageility_SS_BehaviouralData/parse")
setwd("C:/Users/c3155098/OneDrive for Business/2016/Ageility_SS_BehaviouralData/parse")
source("aux_pars.R")
#  setwd("D:/Dropbox/My Documents/LBA/WTF_Sz_results/Ageility_SS_BehaviouralData/Ageility_SS_BehaviouralData/RawData")
setwd("C:/Users/c3155098/OneDrive for Business/2016/Ageility_SS_BehaviouralData/RawData")
Filenames = list.files(pattern="*.csv", full.names=F)

# Set exclusion criteria: 
my_omission=0.10		#exclude participants with go omission rate higher than e.g., 10%
my_error_lnr=0.45		#exclude participants with extremely high error rate (too high even for lognormal race, e.g., 40%)
my_error_beests=0.10	#exclude participants with error rate that is too high for BEESTS, e.g., 10% 
my_RR = c(0.40,0.60)	#exclude participants for which staircase tracking failed to converge to 0.50; maybe slowing or speeding of go responses?
my_short_RR = 0.20	#exlude participants with high response rate on shortes delay; extreme trigger failure rate so no info for parameter estimation OR non-compliance?


# this function returns the subject IDs of subjects who
#	- are eligible for inclusion based on above criteria  
# 	- don't violate context independence: mean go > mean SRRT
#     - have valid go RTs
# also plots some info about min and max RTs, response rates, etc., in jpg format)

# call for controls (just ignore the warnings):
idx = select_subj(filenames=Filenames,my_omission=my_omission,my_error_lnr=my_error_lnr,my_error_beests=my_error_beests,my_RR=my_RR,my_short_RR=my_short_RR)
names(idx)

###------------------------Make data 
subj = idx$subj_beests
#setwd("D:/Dropbox/My Documents/LBA/WTF_Sz_results/Ageility_SS_BehaviouralData/Ageility_SS_BehaviouralData/RawData")
setwd("C:/Users/c3155098/OneDrive for Business/2016/Ageility_SS_BehaviouralData/RawData")

################################################################################################
for(i in subj){

	#####setwd("D:/Dropbox/My Documents/LBA/WTF_Sz_results/Ageility_SS_BehaviouralData/Ageility_SS_BehaviouralData/RawData")
  setwd("C:/Users/c3155098/OneDrive for Business/2016/Ageility_SS_BehaviouralData/RawData")
	data = read.csv(paste(i,".csv",sep=""),header=T) #read csv files from ~/RawData
	go=round(data$rt[(data$target=="Go"&data$accuracy=="Correct") | (data$target=="FirstGo"&data$accuracy=="Correct")],0)	#Draw Go's from data
	go=go[go>150] #only count them if they're greater 150 trials?????
	ngo = length(go) #number of go trials = length of Go vector

	srRT = round(data$rt[(data$target=="Stop"&data$ssaccuracy=="StopFailure")],0) #draw the signal respond RT from data
	srSSD = round(data$ssdelay[(data$target=="Stop"&data$ssaccuracy=="StopFailure")],0) #draw signal respond SSD from data
	srrt=cbind(srSSD,srRT) 
	colnames(srrt)=c("SSD","rt")
	srrt = srrt[srrt[,2]>150,]
	nsrrt = nrow(srrt) #number of Signal Respond trials is the number of rows in "srrt"

	inhib = data$rt[data$target=="Stop"&data$ssaccuracy=="StopSuccess"]
	iSSD = round(data$ssdelay[data$target=="Stop"&data$ssaccuracy=="StopSuccess"],0)

	inh=cbind(iSSD,inhib)
	colnames(inh)=c("SSD","rt")
	inh[,2] = -999
	ninh = nrow(inh)
	
	n_stop = nsrrt+ninh
	RR = nsrrt/n_stop

	Dat = data.frame(ss_presented = c(rep(0,ngo),rep(1,nsrrt),rep(1,ninh)),
				inhibited = c(rep(-999,ngo),rep(0,nsrrt),rep(1,ninh)),
				ssd = c(rep(-999,ngo),srrt[,1],inh[,1]),
				rt = c(go,srrt[,2],rep(-999,ninh)))
	#setwd("D:/Dropbox/My Documents/LBA/WTF_Sz_results/Ageility_SS_BehaviouralData/Ageility_SS_BehaviouralData/DoraBEESTS")
	setwd("C:/Users/c3155098/OneDrive for Business/2016/Ageility_SS_BehaviouralData/PSBEESTS")
	write.csv(Dat,file = paste(i,"_control.csv",sep=""),row.names = F)
}

save(idx,file="idx.RData")









