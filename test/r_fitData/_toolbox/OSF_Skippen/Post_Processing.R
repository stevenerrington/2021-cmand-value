#### Written by Patrick Skippen (patrick.skippen@uon.edu.au). Adapted closely
#### from tutorials in DMC (Andrew Heathcote; http://www.tascl.org/dmc.html;
#### https://osf.io/pbwx8/)

#### Set-up Workspace ####
tmp = load("Model_OUTPUT/Heirachical_EXG3.RData")
source ("dmc/dmc.R")
source('Code/Functions/hyperpars_estab.R')
source('Code/Functions/pars_estab.R')
load_model ("EXG-SS", "exgSSprobit.R")
library(gridExtra)
library(grid)
library(lattice)
library(reshape2)


#Make hierarchical prior
p.prior <- hsamples[[1]]$p.prior

p1 <- get.p.vector(hsamples[[1]])[names(p.prior)]
s.prior <- prior.p.dmc(p1 = p1,
                       p2 = p1,
                       dists = rep("gamma", length(p1)))
pp.prior = list(p.prior, s.prior)

### Simulated Data sets ### - both this object (pp.sim) and the loaded 'pp' will
### be utilsed throughout
pp.sim <-
  h.post.predict.dmc(
    hsamples,
    save.simulation = TRUE,
    cores = 4,
    n.post = 100
  )

# Create posterior predictives to check goodness of fit;
# This can be SLOW unless you have lots of cores available
pp <- h.post.predict.dmc(hsamples, cores = 4, gglist = TRUE)

#### First pdf contains the summary statistics of the hierachical fit and then each participant
pdf("Subject_Summaries.pdf", width = 11, height = 8)

# Summary of populaiton
summary <- data.frame(summary.dmc(hsamples, hyper = T)[2])[1:11,]
colnames(summary) <- c("2.5%", "25%", "50%", "75%", "97.5%")
t <- tableGrob(format(summary, digits = 2))
title <- textGrob(paste("Group level summary statistics"))
grid.arrange(title, t)

# Chains and posteriors for population
plot.dmc(
  hsamples,
  layout = c(3, 2),
  p.prior = pp.prior,
  density = T,
  location = T
)
plot.new()
layout(1)

for (i in seq_along(pp)) {
  # Summary stats for each subj
  summary <- data.frame(summary.dmc(hsamples[[i]])[2])
  colnames(summary) <- c("2.5%", "25%", "50%", "75%", "97.5%")
  t <- tableGrob(format(summary, digits = 2))
  title <-
    textGrob(paste("Summary statistics, Subject", i, sep = " "))
  grid.arrange(title, t)
  
  # Chains and posteriors for each subject
  plot.dmc(
    hsamples[[i]],
    layout = c(3, 2),
    p.prior = pp.prior,
    density = T
  )
  plot.new()
  layout(1)
}

dev.off()


#### Now the posterior predictive checks ####
#set ggplot theme
theme_set(theme_simple())
tmp <- plot_SS_srrt.dmc(
  data = hsamples,
  sim = pp.sim,
  n.intervals = 20,
  violin = .5,
  percentile.av = FALSE
)
tmp <- round(attr(tmp, "cuts"), 2)
xlabels <-
  paste("(", tmp[-length(tmp)], ",", tmp[-1], "]", sep = "")

# Start pdf
pdf("Post_Predictives.pdf", width = 11, height = 8)

# We can now plot observed response proportions and the corresponding
# 95% credible intervals of the posterior predictions
# (i.e., the 2.5% and 97.5% quantiles of the predicted data).
# Because the proportion of
# non-responses on stop trials is of interest we must set the include.NR
# argument to TRUE (by default proportions of trials with an RT response are
# plotted). The graph shows results at the group level, obtained by first
# generating predicted data for each subject and for each posterior sample,
# then taking the average over subjects for each posterior sample.
ggplot.RP.dmc(pp, include.NR = TRUE)

# Next plot the RT distributions, by default as the 10th, 50th and 90th
# percentiles. Note that the NR response level is dropped because by definition
# it has no RT data.

ggplot.RT.dmc(pp)

# Plot average cdf
plot.pp.dmc(
  pp,
  layout = c(2, 2),
  ylim = c(0, 1),
  fits.pcol = "grey",
  model.legend = FALSE,
  dname = "",
  aname = "",
  x.min.max = c(.25, 2)
)

plot.new()
layout(1)

# Heirachical fit Inhibition Function
H_IFTable <-
  plot_SS_if.dmc(
    data = hsamples,
    sim = pp.sim,
    n.intervals = 20,
    violin = .25,
    xlab = "SSD"
  )
title <-
  textGrob("Posterior predictive model check for Inhibition Function")
t <-
  tableGrob(t(H_IFTable), rows = c("SSD (s)", "n delays", "p value"))
grid.arrange(title, t, ncol = 1)

plot.new()
layout(1)

# Hierachical fit Signal Repsonse RT
H_ssrtTable <-
  plot_SS_srrt.dmc(
    data = hsamples,
    sim = pp.sim,
    n.intervals = 20,
    violin = .5,
    percentile.av = FALSE,
    xlabels = xlabels,
    xlab = "SSD (s)"
  )
title <-
  textGrob("Group level posterior predictive model check for Signal Respond RT")
t <-
  tableGrob(t(H_ssrtTable), rows = c("SSD (s)", "n delays", "p value", "N. Sims"))
grid.arrange(title, t, ncol = 1)


# As above for each participant
for (i in seq_along(pp)) {
  plot.new()
  layout(1)
  IF_table <-
    plot_SS_if.dmc(
      data = hsamples[[i]]$data,
      sim = pp.sim[[i]],
      main = paste("Subject", i, sep = " "),
      minN = 6
    )
  title <-
    textGrob(paste(
      "Posterior predictive model check for Inhibition Function, Subject",
      i,
      sep = " "
    )) 
  t <-
    tableGrob(t(IF_table[IF_table$n > 5,]), rows = c("SSD (s)", "n delays", "p value"))
  grid.arrange(title, t, ncol = 1)
  srrt_table <-
    plot_SS_srrt.dmc(
      data = hsamples[[i]]$data,
      sim = pp.sim[[i]],
      main = paste("Subject", i, sep = " "),
      minN = 6
    )
  title <-
    textGrob(paste(
      "Posterior predictive model check for Signal Respond RT, Subject",
      i,
      sep = " "
    )) 
  t <-
    tableGrob(t(srrt_table[srrt_table$nrt > 5,])[-4,], rows = c("SSD (s)", "n trials", "p value"))
  grid.arrange(title, t, ncol = 1)
  
  plot.pp.dmc(
    pp[[i]],
    layout = c(2, 2),
    fits.pcol = "red",
    fits.pch = 20,
    model.legend = F,
    dname = "",
    aname = "",
    x.min.max = c(.25, 2),
    pos = 'topleft',
    style = 'cdf'
  )
  
}
dev.off()


## Priors and posteriors of the hierachical fit
pdf("BlocksRemoved_priors_posteriors.pdf")
par(mfcol = c(2, 3))
for (i in names(p.prior))
  plot.prior(i, p.prior, main = "Mean")
plot.new()
plot.dmc(
  hsamples,
  layout = c(3, 4),
  p.prior = pp.prior,
  location = TRUE,
  density = TRUE,
  hyper = T
)
plot.new()
par(mfcol = c(2, 3))
for (i in names(s.prior))
  plot.prior(i, s.prior, main = "Sigma")
plot.new()
plot.dmc(
  hsamples,
  layout = c(3, 4),
  p.prior = pp.prior,
  scale = TRUE,
  density = T,
  hyper = T
)
dev.off()

#### Figure 2 ####
hyper <- attr(hsamples, "hyper")
hyper.list <- phi.as.mcmc.list(hyper)


hyper.pars <- list()
for (i in colnames(hyper.list[[1]])) {
  hyper.pars[[i]] <- hyperpars.estab(hyper.list, i)
  
}

## Create summary parameters ##
hyper.pars[["SSRT"]] <-
  (hyper.pars[["muS.h1"]] * 1000) + (hyper.pars[["tauS.h1"]] * 1000)
hyper.pars[["SSRTvar"]] <-
  ((hyper.pars[["sigmaS.h1"]] * 1000) ^ 2) + ((hyper.pars[["tauS.h1"]] *
                                                 1000) ^ 2)

hyper.pars[["GoMatchRT"]] <-
  (hyper.pars[["mu.true.h1"]] * 1000) + (hyper.pars[["tau.true.h1"]] * 1000)
hyper.pars[["GoMatchRTvar"]] <-
  ((hyper.pars[["sigma.true.h1"]] * 1000) ^ 2) + ((hyper.pars[["tau.true.h1"]] *
                                                     1000) ^ 2)

hyper.pars[["GoMismatchRTerr"]] <-
  (hyper.pars[["mu.false.h1"]] * 1000) + (hyper.pars[["tau.false.h1"]] *
                                            1000)
hyper.pars[["GoMismatchRTvarerr"]] <-
  ((hyper.pars[["sigma.false.h1"]] * 1000) ^ 2) + ((hyper.pars[["tau.false.h1"]] *
                                                      1000) ^ 2)

hyper.pars[["prob_GF"]] <- pnorm(hyper.pars[["gf.h1"]]) * 100
hyper.pars[["prob_TF"]] <- pnorm(hyper.pars[["tf.h1"]]) * 100


#### Set-up samples parameters ####
pars <- list()
for (i in colnames(hsamples[[1]]$theta)) {
  # same parameter names for each participant, so just use the first one
  pars[[i]] <- pars.estab(hsamples, i)
}

## Create summary parameters ##
pars[["SSRT"]] <- (pars[["muS"]] * 1000) + (pars[["tauS"]] * 1000)
pars[["SSRTvar"]] <-
  ((pars[["sigmaS"]] * 1000) ^ 2) + ((pars[["tauS"]] * 1000) ^ 2)

pars[["GoMatchRT"]] <-
  (pars[["mu.true"]] * 1000) + (pars[["tau.true"]] * 1000)
pars[["GoMatchRTvar"]] <-
  ((pars[["sigma.true"]] * 1000) ^ 2) + ((pars[["tau.true"]] * 1000) ^ 2)

pars[["GoMismatchRTerr"]] <-
  (pars[["mu.false"]] * 1000) + (pars[["tau.false"]] * 1000)
pars[["GoMismatchRTvarerr"]] <-
  ((pars[["sigma.false"]] * 1000) ^ 2) + ((pars[["tau.false"]] * 1000) ^
                                            2)

pars[["prob_TF"]] <- pnorm(pars[["tf"]]) * 100
pars[["prob_GF"]] <- pnorm(pars[["gf"]]) * 100

# Create and save individual figures of each parameter

# SSRT #
SSRT <- data.frame(pars$SSRT)
SSRT.long <- melt(t(SSRT))
SSRT.long$Var2 <- as.factor(SSRT.long$Var2)

SSRT.plot <- ggplot(SSRT.long, aes(x = value, colour = Var2)) +
  geom_line(stat = 'density') +
  theme_classic(base_size = 30, base_family = 'serif') +
  labs(x = "Stop Signal Reaction Time",
       y = "Density", colour = "") +
  scale_colour_grey() +
  theme(legend.position = "none") +
  scale_x_continuous(limits = c(0, 400))


final_SSRT.plot <-
  SSRT.plot + geom_line(aes(as.data.frame(as.vector(hyper.pars$SSRT))), color =
                          "red", stat = "density")

ggsave('Model_OUTPUT/SSRT.png')


# Go Matching RT #
GoRT <- data.frame(pars$GoRT)
GoRT.long <- melt(t(GoRT))
GoRT.long$Var2 <- as.factor(GoRT.long$Var2)

GoRT.plot <- ggplot(GoRT.long, aes(x = value, colour = Var2)) +
  geom_line(stat = 'density') +
  theme_classic(base_size = 30, base_family = 'serif') +
  labs(x = "Matching Finishing Time",
       y = "Density", colour = "") +
  scale_colour_grey() +
  theme(legend.position = "none") +
  scale_x_continuous(limits = c(350, 1000))


final_GoRT.plot <-
  GoRT.plot + geom_line(aes(as.data.frame(as.vector(hyper.pars$GoRT))), color =
                          "red", stat = "density")

ggsave('Model_OUTPUT/GoMatchRT.png')

# prob_TF #
prob_TF <- data.frame(pars$prob_TF)
prob_TF.long <- melt(t(prob_TF))
prob_TF.long$Var2 <- as.factor(prob_TF.long$Var2)

prob_TF.plot <-
  ggplot(prob_TF.long, aes(x = value, colour = Var2)) +
  geom_line(stat = 'density') +
  theme_classic(base_size = 30, base_family = 'serif') +
  labs(x = "Probability Trigger Failure",
       y = "Density", colour = "") +
  scale_colour_grey() +
  theme(legend.position = "none") +
  scale_x_continuous(limits = c(0, 100))


final_prob_TF.plot <-
  prob_TF.plot + geom_line(aes(as.data.frame(as.vector(hyper.pars$prob_TF))), color =
                             "red", stat = "density")

ggsave('Model_OUTPUT/prob_TF.png')

# prob_GF #
prob_GF <- data.frame(pars$prob_GF)
prob_GF.long <- melt(t(prob_GF))
prob_GF.long$Var2 <- as.factor(prob_GF.long$Var2)

prob_GF.plot <-
  ggplot(prob_GF.long, aes(x = value, colour = Var2)) +
  geom_line(stat = 'density') +
  theme_classic(base_size = 30, base_family = 'serif') +
  labs(x = "Probability Go Failure",
       y = "Density", colour = "") +
  scale_colour_grey() +
  theme(legend.position = "none") +
  scale_x_continuous(limits = c(0, 30))


final_prob_GF.plot <-
  prob_GF.plot + geom_line(aes(as.data.frame(as.vector(hyper.pars$prob_GF))), color =
                             "red", stat = "density")

ggsave('Model_OUTPUT/prob_GF.png')

## Table 2 ##
hyper.summ <- list()

for (i in names(hyper.pars)) {
  hyper.summ[[i]] <- quantile(hyper.pars[[i]], c(0.5, 0.025, 0.975))
  
}
write.csv(
  t(as.data.frame(hyper.summ)),
  file = paste(getwd(), "/Model_OUTPUT/Model_Parameter_Summary.csv", sep = "")
)
