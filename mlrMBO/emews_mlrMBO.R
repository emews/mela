## mlrMBO based EMEWS model exploration library

# Set working directory to EMEWS project "R" directory
# if run as part of an EMEWS workflow
emews_root <- Sys.getenv("EMEWS_PROJECT_ROOT")
if (emews_root == "") {
  r_root <- getwd()
} else {
  r_root <- paste0(emews_root, "/R")
}
wd <- getwd()
setwd(r_root)

# Source utility functions
source("mlrMBO_utils.R")

# EQ/R based parallel map
parallelMap2 <- function(fun, ...,
                         more.args = list(),
                         simplify = FALSE,
                         use.names = FALSE,
                         impute.error = NULL,
                         level = NA_character_,
                         show.info = NA){
  st = proc.time()

  # transform data structure passed as ...
  # into EMEWS string convention: a1,b1,c1;a2,b2,c2;a3,b3,c3
  # where each semicolon (;) separated tuble an,bn,cn
  # is a parameter combination
  dots <- list(...)
  string_params <- elements_of_lists_to_string(dots[[1L]])
  #print(paste0("parallelMap2 called with list_param: ",string_params))

  # Insert string representation into EQ/R OUT queue
  OUT_put(string_params)

  # Receive string representation of evaluated objective functions
  # from EQ/R IN queue
  string_results = IN_get()

  st = proc.time() - st

  # Assumes results are in the form a;b;c
  # Note: can also handle vector returns for each,
  # i.e., a,b;c,d;e,f
  res <- string_to_list_of_vectors(string_results)

  # Return results with timing information for
  # running this invocation of parallelMap2
  return(result_with_extras_if_exist(res,st[3]))
}

require(parallelMap)

unlockBinding("parallelMap", as.environment("package:parallelMap"))
assignInNamespace("parallelMap", parallelMap2, ns="parallelMap", envir=as.environment("package:parallelMap"))
assign("parallelMap", parallelMap2, as.environment("package:parallelMap"))
lockBinding("parallelMap", as.environment("package:parallelMap"))

library(mlrMBO)

# dummy objective function
# actual objective function is defined as part of the
# model component of the workflow
dummy.obj.fun = function(x){}

# par.set is used to define the parameters and ranges
# see http://berndbischl.github.io/ParamHelpers/man/makeParamSet.html
obj.fun = makeSingleObjectiveFunction(
  name = "Numeric 2D",
  fn = dummy.obj.fun,
  par.set = makeParamSet(
    makeNumericParam("x1", lower = -5, upper = 5),
    makeNumericParam("x2", lower = -10, upper = 20)
  )
)

# main function using multiple point proposals for parallelism
# see: https://mlr-org.github.io/mlrMBO/articles/supplementary/parallelization.html
main_function <- function(pp = 2, it = 5){
  ctrl = makeMBOControl(propose.points = pp)
  ctrl = setMBOControlInfill(ctrl, crit = crit.ei)
  ctrl = setMBOControlMultiPoint(ctrl, method = "cl", cl.lie = min)
  ctrl = setMBOControlTermination(ctrl, iters = it)
  #ctrl = setMBOControlTermination(ctrl, max.evals = 10)
  configureMlr(on.learner.warning = "quiet", show.learner.output = FALSE)

  res = mbo(obj.fun, control = ctrl, show.info = FALSE)
  return(res)
}

## Initial handshake
# ask for parameters from queue
OUT_put("Params")
# accepts arguments to main_function, e.g., "pp = 2, it = 5"
res <- IN_get()

# mlrMBO specific parameters received via handshake
# are used to call the main function
l <- eval(parse(text = paste0("list(",res,")")))
final_res <- do.call(main_function,l)

# main function completed
OUT_put("DONE")

# Outputting results of main function into TURBINE_OUTPUT,
# i.e., experiment, directory
turbine_output <- Sys.getenv("TURBINE_OUTPUT")
if (turbine_output != "") {
  setwd(turbine_output)
}
# This will be saved to experiment directory
saveRDS(final_res,file = "final_res.Rds")

# Revert to original working directory
setwd(wd)

# Push final message into EQ/R OUT queue
OUT_put("Look at final_res.Rds for final results.")
print("algorithm done.")
