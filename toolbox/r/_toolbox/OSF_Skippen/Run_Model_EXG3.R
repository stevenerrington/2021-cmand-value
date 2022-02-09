#### Script to fit the EXG3 model to the data
#### Functions and further descriptions are presented in the DMC materials
#### (Andrew Heathcote; http://www.tascl.org/dmc.html; https://osf.io/pbwx8/)

source ("dmc/dmc.R")
load_model ("EXG-SS", "exgSSprobit.R")
tmp = load("DataForModelling/EXG3Model.RData")
cores = 4 # Many of the functions below can utilise multiple cores. Recommend running from HPC to run this on


### Initialise and run samples level objects
samples <- h.samples.dmc(nmc = 120, p.prior, data = dm)
samples <- h.run.dmc(samples,
                     cores = cores,
                     report = 1,
                     p.migrate = 0.05)
samples1 <- h.RUN.dmc(samples, cores = cores, max.try = 100)
save(dm, samples, samples1, file = "Model_OUTPUT/Samples_EXG3.RData")

# Make hierarchical priors
p.prior <- samples1[[1]]$p.prior

p1 <- get.p.vector(samples1[[1]])[names(p.prior)]
s.prior <- prior.p.dmc(p1 = p1,
                       p2 = p1,
                       dists = rep("gamma", length(p1)))
pp.prior = list(p.prior, s.prior)

hstart <- make.hstart(samples1)
theta1 <- make.theta1(samples1)
hsamples <- h.samples.dmc(
  nmc = 100,
  p.prior,
  dm,
  pp.prior,
  hstart.prior = hstart,
  theta1 = theta1,
  thin = 10
)

#### STAGE 2 - Heirachical ####
hsamples <-
  h.run.dmc(
    hsamples,
    p.migrate = .05,
    h.p.migrate = .05,
    cores = cores,
    report = 1
  )
hsamples  <-
  h.run.unstuck.dmc(
    hsamples,
    p.migrate = .05,
    h.p.migrate = .05,
    cores = cores,
    report = 1
  )
hsamples <-
  h.run.converge.dmc(
    h.samples.dmc(nmc = 100, samples = hsamples),
    thorough = TRUE,
    nmc = 50,
    cores = cores,
    finalrun = TRUE,
    finalI = 250
  )
hsamples <-
  h.run.dmc(h.samples.dmc(samples = hsamples, nmc = 200),
            cores = cores,
            report = 10)

save(dm, hsamples, samples1, file = "Model_OUTPUT/Heirachical_EXG3.RData")

#### Quick View summmary stats ####
h.IC.dmc(hsamples, DIC = TRUE)

gelman.diag.dmc(hsamples, hyper = TRUE)
gelman.diag.dmc(hsamples)

tmp <- summary.dmc(hsamples, hyper = TRUE)$quantiles
round(tmp[, c(1, 3, 5)], 3)