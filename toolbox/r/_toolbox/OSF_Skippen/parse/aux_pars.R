select_subj = function(filenames, path, my_omission,my_error_lnr,my_error_beests,my_RR,my_short_RR,my_slowing){

	idx=gsub(".csv", "", filenames)
	N=length(idx)
	trials = data.frame(subj_idx=rep(NA,N),

			    #-------------------------------------------- All kind of checks

			    n_goAll=rep(NA,N),min_goAll=rep(NA,N),max_goAll=rep(NA,N),mean_goAll=rep(NA,N),						#all go trials
			    n_go=rep(NA,N),min_go=rep(NA,N),max_go=rep(NA,N),mean_go=rep(NA,N),								#go trials exclusive omissions
			    n_goC=rep(NA,N),min_goC=rep(NA,N),max_goC=rep(NA,N),mean_goC=rep(NA,N),							#go trials exclusive omissions & errors
			    omission=rep(NA,N),error=rep(NA,N),

			    n_srrt=rep(NA,N),min_srrt=rep(NA,N),max_srrt=rep(NA,N),mean_srrt=rep(NA,N),						#all signal-respond trials
			    n_srrtC=rep(NA,N),min_srrtC=rep(NA,N),max_srrtC=rep(NA,N),mean_srrtC=rep(NA,N),error_srrt=rep(NA,N), 		#signal-respond trials exclusive errors

			    n_stop=rep(NA,N),n_inhib=rep(NA,N), 													#signal-inhibit trials
			    RR=rep(NA,N),	     			    													#response rate based on all signal-respond trials
			    RRC=rep(NA,N),     			    													#response rate based on correct signal-respond trials
			    
			    early_SSD=rep(NA,N),	    	   	 												#RR at shortest delay/n_stop --> if high, subject is not doing task

			    #-----------------------------------------filtering
			    independence=rep(NA,N),		    		#FALSE: context independence violated based on mean(go)>mean(srrt)
			    independenceC=rep(NA,N),		   		#FALSE: context independence violated based on mean(goC)>mean(srrtC)
			    
			    include_omission=rep(NA,N),	   	 	#FALSE: omission rate is higher than my_omission
			    include_error_lnr=rep(NA,N),	   	 	#FALSE: error rate is higher than my_error_lnr 
			    include_error_beests=rep(NA,N),   	 	#FALSE: error rate is higher than my_error_beests
			    include_RR_lnr=rep(NA,N),	   	 	 	#FALSE: response rate is not within allowable range supplied in my_RR (based on RR)
			    include_RR_beests=rep(NA,N),   	 	 	#FALSE: response rate is not within allowable range supplied in my_RR (based  on RRC)
			    include_short_RR=rep(NA,N),   	 	 	#FALSE: response rate on shortest SSD is higher than my_short_RR
			    include_slowing=rep(NA,N),
			    ics=rep(NA,N),
			    slopes=rep(NA,N))
			    
	for(i in 1:N){
	
		data = read.csv(paste(path,filenames[i],sep = ""),header=T)
		data$ssdelay=round(data$ssdelay)
		data$rt=round(data$rt)
		trials[i,"subj_idx"] = idx[i]

		goAll=data$rt[data$target=="Go" | data$target=="FirstGo"]			#inlc omissions & errors
		trials[i,"n_goAll"]=length(goAll)
		trials[i,"min_goAll"]=min(goAll[goAll!=0],na.rm=T)
		trials[i,"max_goAll"]=max(goAll[goAll!=0],na.rm=T)
		trials[i,"mean_goAll"]=mean(goAll[goAll!=0],na.rm=T)

		go=data$rt[(data$target=="Go"&data$accuracy!="NoResponse") | (data$target=="FirstGo"&data$accuracy!="NoResponse")]	#incl error but excl. omissions --> for SS-LNR
		trials[i,"n_go"]=length(go)
		trials[i,"min_go"]=min(go)
		trials[i,"max_go"]=max(go)
		trials[i,"mean_go"]=mean(go)
		
    # # Check for slowing
    trial_tmp=data$trial[(data$target=="Go"&data$accuracy!="NoResponse") | (data$target=="FirstGo"&data$accuracy!="NoResponse")]
    trial=trial_tmp/max(data$trial)
    lms <- lm(go~trial)
    trials[i,"ics"] <- lms$coefficients[1]
    slope <- lms$coefficients[2]
    trials[i,"slopes"] <- slope
 
		goC=data$rt[(data$target=="Go"&data$accuracy=="Correct") | (data$target=="FirstGo"&data$accuracy=="Correct")] 		#excl. omissions and errors --> for BEESTS
		trials[i,"n_goC"]=length(goC)
		trials[i,"min_goC"]=min(goC)
		trials[i,"max_goC"]=max(goC)
		trials[i,"mean_goC"]=mean(goC)

		omission = 1-(length(go)/length(goAll))
		trials[i,"omission"]=omission
		error = 1-(length(goC)/length(go))
		trials[i,"error"]=error

		#------------------------------------------------------------------------------------------------
		srrt = data$rt[(data$target=="Stop"&data$ssaccuracy=="StopFailure") | (data$target=="Stop"&data$ssaccuracy=="StopFailureError")]
		trials[i,"n_srrt"]=length(srrt)
		trials[i,"min_srrt"]=min(srrt)
		trials[i,"max_srrt"]=max(srrt)
		trials[i,"mean_srrt"]=mean(srrt)

		srrtC = data$rt[(data$target=="Stop"&data$ssaccuracy=="StopFailure")]
		trials[i,"n_srrtC"]=length(srrtC)
		trials[i,"min_srrtC"]=min(srrtC)
		trials[i,"max_srrtC"]=max(srrtC)
		trials[i,"mean_srrtC"]=mean(srrtC)
		error_srrt = 1-(length(srrtC)/length(srrt))
		trials[i,"error_srrt"]=error_srrt

		#---------------------------------------------------------------------------------------------------
		n_stop = nrow(data[data$target=="Stop",])
		trials[i,"n_stop"]=n_stop
		trials[i,"n_inhib"] = nrow(data[data$target=="Stop"&data$ssaccuracy=="StopSuccess",])
		RR = length(srrt)/n_stop
		trials[i,"RR"] = RR
		RRC =  length(srrtC)/n_stop
		trials[i,"RRC"] = RRC

		#----------------------------------------------------------------------------------------------------
		ssd = min(data$ssdelay[data$target=="Stop"])
		firstRR = length(data$rt[data$target=="Stop"&data$ssaccuracy!="StopSuccess"&data$ssdelay==ssd])/n_stop
 		trials[i,"early_SSD"] = firstRR

		#----------------------------------------------------------------------------------------------------
		trials[i,"independence"]=mean(go)>mean(srrt)
		trials[i,"independenceC"]=mean(goC)>mean(srrtC)

		#----------------------------------------------------------------------------------------------------
		trials[i,"include_omission"] = omission<my_omission
		trials[i,"include_error_lnr"] = (error<my_error_lnr &error_srrt<my_error_lnr)
		trials[i,"include_error_beests"] = (error<my_error_beests &error_srrt<my_error_beests)
		trials[i,"include_RR_lnr"] = (RR>my_RR[1] & RR<my_RR[2])
		trials[i,"include_RR_beests"] = (RRC>my_RR[1] & RRC<my_RR[2])
		trials[i,"include_short_RR"] = firstRR<my_short_RR
    trials[i,"include_slowing"] = (slope>my_slowing[1] & slope<my_slowing[2])
		#-----------------------------------------------------------------------------------------plot stuff
			delays_all = sort(unique(data$ssdelay[data$target=="Stop"]))
 			n_delays_all = length(delays_all)
  			n_observed_srrt_all = rep(0,n_delays_all)
  			n_observed_inhibit_all = rep(0,n_delays_all)
  
  			for(d2 in 1:n_delays_all){
    				n_observed_srrt_all[d2] = nrow(data[data$target=="Stop"&data$ssaccuracy=="StopFailure"&data$ssdelay==delays_all[d2],])
    				n_observed_inhibit_all[d2] = nrow(data[data$target=="Stop"&data$ssaccuracy=="StopSuccess"&data$ssdelay==delays_all[d2],])
  			}
  			n_observed_all = n_observed_srrt_all + n_observed_inhibit_all
  
			# select delays with at least one srrt for posterior predictive checks for median srrt and srrt distributions
			# and get observed SRRTs per delay; and compute median
			delays = sort(unique(data$ssdelay[data$target=="Stop"&data$ssaccuracy=="StopFailure"]))
			n_delays = length(delays)

			median_observed_srrt = rep(NA,length(delays))
			n_observed_srrt = rep(NA,length(delays))
			n_observed_inhibit = rep(NA,length(delays))
 			srrt_obs = list()
  
			for (d in 1:n_delays){
				srrt_temp = data$rt[data$target=="Stop"&data$ssaccuracy=="StopFailure"&data$ssdelay==delays[d]]
				srrt_obs[[d]] = srrt_temp
				median_observed_srrt[d] = median(srrt_temp)
				n_observed_srrt[d] = length(srrt_temp)
				n_observed_inhibit[d] = nrow(data[data$target=="Stop"&data$ssaccuracy=="StopSuccess"&data$ssdelay==delays[d],])
			}
			n_observed = n_observed_srrt + n_observed_inhibit

  			RR_obs = n_observed_srrt_all/n_observed_all

			jpeg(paste(getwd(),"/Aux_pars_OUTPUT/",idx[i],"_control.jpg",sep=""))
				layout(matrix(1:4,2)) #removed comma after 2
				hist(go)
				plot(delays,median_observed_srrt,type="l",main="signal respond RT")
				plot(delays_all,RR_obs,type="l",main="Inhibition function")
			dev.off()
	}

		jpeg(paste(getwd(),"/Aux_pars_OUTPUT/","group_cheks.jpg",sep=""), width = 800, height = 800)
			layout(matrix(1:16,4))	
			hist(trials$min_go)
			hist(trials$max_go)
			hist(trials$min_goC)
			hist(trials$max_goC)
		
			hist(trials$min_srrt)
			hist(trials$max_srrt)
			hist(trials$min_srrtC)
			hist(trials$max_srrtC)

			hist(trials$omission)
			hist(trials$error)
			hist(trials$error_srrt)
			hist(trials$RR)
			hist(trials$RRC)
		
			hist(trials$early_SSD)
			plot(trials$omission,trials$error)
		dev.off()

		include_beests = trials$include_omission&trials$include_error_beests&trials$include_RR_beests&trials$include_short_RR#&trials$independenceC - re-add later 
		include_lnr = trials$independence&trials$include_omission&trials$include_error_lnr&trials$include_RR_lnr&trials$include_short_RR&trials$include_slowing
	
		return(list(original_N = N, subj_beests = trials$subj_idx[include_beests], subj_lnr = trials$subj_idx[include_lnr],checks=trials,include=include_lnr))
}