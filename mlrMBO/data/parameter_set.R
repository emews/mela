# see https://cran.r-project.org/web/packages/ParamHelpers/ParamHelpers.pdfmakeNum
param.set <- makeParamSet(
  makeNumericParam("x1", lower = -5, upper = 5),
  makeNumericParam("x2", lower = -10, upper = 20)
)
