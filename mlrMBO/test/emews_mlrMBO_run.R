## Assumes working directory is ../
# run using source("test/emews_mlrMBO_run.R")

source("test/test_utils.R")

# Simple objective function for testing
simple.obj.fun <- function(x){
  sum(x^2)
}

# Functions to supply OUT_put and IN_get
for.In_get = ""
last.time = FALSE
OUT_put <- function(x) {
  if (!last.time){
    if (x == "DONE"){
      for.In_get <<- "Look at final_res.Rds for final results."
      last.time <<- TRUE
    }
    else if (x == "Params") {
      ## Handshake protocol
      for.In_get <<- "pp = 2, it = 5"
    }
    else {
      res <- split.into.param.lines(x)
      resFull <- lapply(res,simple.obj.fun)
      for.In_get <<- make.into.q.res(resFull)
    }
  }
  else {
    print(x)
  }
}
IN_get <- function(){
  print(paste0("returning: ", for.In_get))
  return(for.In_get)
}


source("emews_mlrMBO.R")

## Look at result with: readRDS("final_res.Rds")
