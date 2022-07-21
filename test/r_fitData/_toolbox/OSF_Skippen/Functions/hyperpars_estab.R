hyperpars.estab <- function(hsamples,parameter){
  out <- do.call(cbind, lapply(hsamples, function(x) {unlist(x[, parameter ])
  }))
  return(out)
}