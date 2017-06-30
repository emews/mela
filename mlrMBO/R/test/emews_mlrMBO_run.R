## Assumes working directory is ../
# run using source("test/emews_mlrMBO_run.R")

source("test/test_utils.R")

# Simple objective function for testing
# don't call it simple.obj.fun
simple.obj.fun2 <- function(x){
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
      for.In_get <<- "max.budget = 30, max.iterations = 2, design.size=10, propose.points=3, param.set.file='../data/parameter_set.R'"
    }
    else {
      res <- split.json.into.dummy.param.lines(x)
      print(paste0("res: ",res))
      resFull <- lapply(res,simple.obj.fun2)
      print(paste0("resFull = ", resFull))
      #for.In_get <<- make.into.q.res(resFull)
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
