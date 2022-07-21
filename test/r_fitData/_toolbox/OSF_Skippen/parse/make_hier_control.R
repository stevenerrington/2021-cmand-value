rm(list=ls())
setwd("C:/Users/c3155098/OneDrive for Business/2016/Ageility_SS_BehaviouralData/PSBEESTS")
load("idx.RData")

subj = idx$subj_beests

data_hier = data.frame()

for(i in 1:length(subj)){
		dat = read.csv(file=paste(subj[i],"_control.csv",sep=""),head=TRUE,sep=",")
		rows = nrow(dat)
		subj_idx = rep(i,rows)
		dat = cbind(subj_idx,dat)
		data_hier = rbind(data_hier,dat)
}

write.csv(data_hier,file = "BEESTS_HData.csv",row.names = F)

subj_idx = cbind(subj,1:length(subj))
colnames(subj_idx) = list("subj_idx","BEESTS_num")
save(subj_idx,file="subj_idx_forBEESTS.RData")
