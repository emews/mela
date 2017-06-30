# Split the string pushed into OUT_put into
# list of numerical vectors (used in simple_mlrMBO_run_test.R)
split.into.param.lines <- function(x){
  res1 <- unlist(strsplit(x,split = ";"))
  lapply(strsplit(res1,split = ","), function(x) as.numeric(x))
}

split.json.into.dummy.param.lines <- function(x){
  res1 <- unlist(strsplit(x,split = ";"))
  l <- length(res1)
  res <- 1:l
  return(res)
}

make.into.q.res <- function(x){
  paste0(x,collapse = ";")
}
