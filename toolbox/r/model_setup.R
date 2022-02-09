
tmp = load("./_data/2021_dajo_cleanData.RData")
dat$sessionName <- factor(dat$sessionName)


ModDat <-
  dat[, c("sessionName",
          "ssd",
          "targetLoc",
          "trialType",
          "response",
          "rt")]
names(ModDat) <- c("s", "SSD", "S", "SS", "R", "RT")
ModDat$SS <-
  factor(ModDat$SS)
levels(ModDat$SS) <- c("Go", "Stop")
ModDat$SSD[ModDat$SS == "Go"] <- Inf
ModDat$R <-
  factor(ModDat$R, levels = c("NoResponse", "Left", "Right"))
levels(ModDat$R) <- c("NoResponse", "Left", "Right")
ModDat$S <- factor(ModDat$S)
ModDat$RT[ModDat$R == "NoResponse"] <- NA


# Censor RT distribution
hist(ModDat$RT, breaks = "fd")
head(sort(ModDat$RT), 200)
tail(sort(ModDat$RT), 100)

# 200 to 700 ms
fast <- ModDat$RT < 200
fast[is.na(fast)] <- FALSE
slow <- ModDat$RT > 700
slow[is.na(slow)] <- FALSE
ModDat <- ModDat[!fast & !slow,]


levels(ModDat$S) <- c("targ_left", "targ_right")
levels(ModDat$R) <- c("NR", "resp_left", "resp_right")
levels(ModDat$SS) <- c("go", "stop")
save(ModDat, file = "_data/2021_dajo_modelData.RData")

###################################################
#### DMC Toolbox 
### Set-up workspace
setwd('./_toolbox/DMC_190819/')
source ("./dmc/dmc.R") # lots of package dependencies; check you have these installed, if not you will get a warning message
load_model ("EXG-SS","exgSS.R")
tmp = load("../../_data/2021_dajo_modelData.RData")

### Set-up model
model <- model.dmc(
  # SS stands for trial type (GO or Stop-signal [SS]):
  factors=list(S=c("targ_left","targ_right"),SS=c("go","stop")),
  # NR stands for "No response", i.e., go omission & successful inhibitions:
  responses=c("NR","resp_left","resp_right"),
  # Match scores correct responses for each GO stimulus as usual, and scores 
  # the "correct" stimulus corresponding to an NR response, but the latter has
  # no effect (it just avoids a standard check making sure that each response is scored): 
  match.map=list(M=list(targ_left="resp_left",targ_right="resp_right",targ_left="NR")),
  p.map=list(mu="M",sigma="M",tau="M",tf="1",muS="1",sigmaS="1",tauS="1",gf="1"),
  # No errors:
  constants=c(mu.false=1e6,sigma.false=.001,tau.false=.001),
  type="exgss")

p.vector  <- c(mu.true=.3,muS=.15,sigma.true=.05,sigmaS=.03,tau.true=.08,tauS=.05,tf=.1,gf=.1) 
check.p.vector(p.vector,model)


#######################################################
#### Check data integrity and general stopping summaries
# Plot GO RT distrbution
correct <- as.numeric(ModDat$S)==(as.numeric(ModDat$R)-1)
layout(1)
plot.cell.density(ModDat[ModDat$SS=="go",],
                  C=correct[ModDat$SS=="go"],
                  main="Go RTs")

# Overall accuracy on go task
# (i.e., proportion go omissions in this case; remember, no errors!):
tapply(as.numeric(ModDat$S)==(as.numeric(ModDat$R)-1),ModDat$SS,mean,na.rm=TRUE)["go"]


# Show the different SSDs:
tapply(as.character(ModDat$SSD),ModDat[,c("SS")],unique)$stop

# Show the number of trials for each SSD:
Ns = tapply(ModDat$RT,ModDat$SSD,length)
Ns

# Response rate broken down by SSD & corresponding inhibition function:
tapply(!is.na(ModDat$RT),ModDat[,c("SS","SSD")],mean)
plot_SS_if.dmc(ModDat)  #P(Respond) increases as a function of SSD, as it should

# Plot median signal-respond RT per SSD:
tapply(ModDat$RT,ModDat$SSD,median,na.rm=TRUE) 
plot_SS_srrt.dmc(ModDat) # Median SRRT increases as a function of SSD, as it should

# Signal-respond RTs should be faster than go RTs:
hist(ModDat$RT[ModDat$SS=="go"],breaks="fd",main="SRRT vs. Go RT",freq=F,ylim=c(0,0.012))
lines(density(ModDat$RT[ModDat$SS=="go"],na.rm=T),col="black",lwd=2)
lines(density(ModDat$RT[ModDat$SS=="stop"],na.rm=T),col="red",lwd=2)


#######################################################
# Plot priors: (I'll need to double check all this...)
p1 <- p.vector; p1[1:length(p1)] <- 1; p1
p.prior <- prior.p.dmc(
  dists = rep("beta",length(p1)),p1=p1,p2=rep(1,length(p1)), # Uniform(0,1)
  lower=rep(0,length(p1)),upper=c(rep(2,2),rep(.5,4),rep(1,2)) # Scale to Uniform(lower,upper)
)

par(mfcol = c(2, 4))
for (i in names(p.prior))
  plot.prior(i, p.prior)

#######################################################
# Bind the data and model
dm <- data.model.dmc(ModDat, model)

# Save the output
save(dm, p.prior, file = "../../_data/2021_dajo_EXGmodel.RData")

