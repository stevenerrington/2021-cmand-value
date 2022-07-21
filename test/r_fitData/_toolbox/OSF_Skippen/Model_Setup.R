#### Code taken from tutorials in DMC materials (Andrew Heathcote;
#### http://www.tascl.org/dmc.html; https://osf.io/pbwx8/) Organises clean data
#### for modelling and initialises model object.

tmp = load("DataForModelling/Clean_Data.RData")
dat$subject <- factor(dat$subject)

ModDat <-
  dat[, c("subject",
          "ssdelay",
          "correctresponse",
          "target",
          "response",
          "rt")]
names(ModDat) <- c("s", "SSD", "S", "SS", "R", "RT")
ModDat$SS <-
  factor(ModDat$SS)
levels(ModDat$SS) <- c("GO", "GO", "SS")
ModDat$SSD[ModDat$SS == "GO"] <- Inf
ModDat$R <-
  factor(ModDat$R, levels = c("NoResponse", "Left", "Right"))
levels(ModDat$R) <- c("NR", "Left", "Right")
ModDat$S <- factor(ModDat$S)
ModDat$RT[ModDat$R == "NR"] <- NA
ModDat$RT <- ModDat$RT / 1000

table(ModDat$SS, ModDat$s) # Roughly; 500 go and 200 stop

# Censor RT distribution
hist(ModDat$RT, breaks = "fd")
head(sort(ModDat$RT), 200)
tail(sort(ModDat$RT), 100)

# .2 to 2s
fast <- ModDat$RT < .2
fast[is.na(fast)] <- FALSE
slow <- ModDat$RT > 2
slow[is.na(slow)] <- FALSE
ModDat <- ModDat[!fast & !slow,]

levels(ModDat$S) <- c("s1", "s2")

levels(ModDat$R) <- c("NR", "r1", "r2")

levels(ModDat$SS) <- c("go", "stop")

ModDat$SSD <- ModDat$SSD / 1000

save(ModDat, file = "Output/Model_Data.RData")

### Set-up workspace
source ("dmc/dmc.R") # lots of package dependencies; check you have these installed, if not you will get a warning message
load_model ("EXG-SS", "exgSSprobit.R")
tmp = load("DataForModelling/Model_Data.RData")

### Set-up model
factors <- list(S = c("s1", "s2"), SS = c("go", "stop"))
model <- model.dmc(
  p.map = list(
    mu = c("M"),
    sigma = c("M"),
    tau = c("M"),
    muS = "1",
    sigmaS = "1",
    tauS = "1",
    tf = "1",
    gf = "1"
  ),
  match.map = list(M = list(
    s1 = "r1", s2 = "r2", s1 = "NR"
  )),
  factors = factors,
  responses = c("NR", "r1", "r2"),
  type = "exgss"
)

p.vector <- attributes(model)$p.vector
p1 <-
  p.vector
p1[1:length(p1)] <-
  c(rep(.5, 2), rep(.2, 4), .5, .2, .2,-1.5,-1.5)
p.prior <- prior.p.dmc(
  dists = rep("tnorm", length(p.vector)),
  p1 = p1,
  p2 = rep(1, length(p.vector)),
  lower = c(rep(0, 9), NA, NA),
  upper = c(c(4, 8, 4, 8, 4, 8, 4, 4, 4, NA, NA))
)
# Plot priors
par(mfcol = c(2, 6))
for (i in names(p.prior))
  plot.prior(i, p.prior)

### Bind the data and model
dm <- data.model.dmc(ModDat, model)
save(dm, p.prior, file = "DataForModelling/EXG3Model.RData")
