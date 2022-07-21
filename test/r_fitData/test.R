###################################################################
#### Run LBA simulations using derived parameters
ntrials = length(input_rt_data);
LBA_rt<- rlba_norm(ntrials,A=LBA_param$par["A"],b=LBA_param$par["b"],t0 = LBA_param$par["t0"],
                   mean_v=LBA_param$par["mean_v"], sd_v=LBA_param$par["sd_v"])

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
#### Quantify the fit
# Kolmogorov-Smirnov
dist_comparison_ks = ks.test(input_rt_data, LBA_rt[,1])


###################################################################
#### Output data
out_data <- data.frame(session=session_name,
                       lba_param_a = LBA_param$par["A"],
                       lba_param_b = LBA_param$par["b"],
                       lba_param_t0 = LBA_param$par["t0"],
                       lba_param_mean_v = LBA_param$par["mean_v"],
                       lba_param_sd_v = LBA_param$par["sd_v"],
                       lba_param_convergence = LBA_param$convergence,
                       lba_param_objective = LBA_param$objective,
                       lba_param_function = LBA_param$evaluations["function"],
                       lba_param_gradient= LBA_param$evaluations["gradient"],
                       ks_kstat = dist_comparison_ks$statistic[["D"]],
                       ks_pvalue = dist_comparison_ks$p.value,
                       stringsAsFactors=FALSE) 
