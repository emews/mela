# An mlrMBO based EMEWS model exploration (ME) module #


## ME algorithm details ##
This example presents an R-based ME algorithm (`R/emews_mlrMBO.R`) utilizing the mlrMBO (https://mlr-org.github.io/mlrMBO/) R package. See https://arxiv.org/abs/1703.03373 for a detailed description of model-based optimization and mlrMBO capabilities.

The ME algorithm minimizes an objective function for a parameter space defined using the ParamHelpers library.
 For example,
```R
  par.set = makeParamSet(
    makeNumericParam("x1", lower = -5, upper = 5),
    makeNumericParam("x2", lower = -10, upper = 20))
```
This defines the two dimensional space `(x1,x2)` with the specified limits.  This is defined in the `data/parameter_set.R` file, and is read in by the algorithm. See http://berndbischl.github.io/ParamHelpers/man/makeParamSet.html for more details on defining parameter sets.

We make use of existing capabilities from mlrMBO:
* **expected improvement** for the infill criterion
* **constant liar** for multi-point proposals

The example uses **multi-point proposals** for concurrency in the iterative steps, defined via a `propose.points=<number of proposed points>` passed in via the [handshake protocol](#handshake-protocol). See https://mlr-org.github.io/mlrMBO/articles/supplementary/parallelization.html for more information on parallelization in mlrMBO.

The maximum algorithm iteration is specified via a `max.iterations=<number of max iterations>` argument, also defined via the [handshake protocol](#handshake-protocol).

### ME output file: final_res.Rds ###
mlrMBO's mbo function produces a MBOSingleObjResult object. That object is
saved to the file system either to the R directory or, if within an EMEWS workflow, to the experiment directory as `final_res.Rds` and can be loaded within an R session using `readRDS("<path to>/final_res.Rds")`. The results contain the final best parameter values (the 'x' attribute) and associated metadata about the parameter evaluations. Sample R
session:

```R
> res <- readRDS("final_res.Rds")
> res
Recommended parameters:
x1=-0.00348; x2=0.00039
Objective: y = 0.000

Optimization path
10 + 50 entries in total, displaying last 10 (or less):
             x1            x2          y dob eol error.message exec.time           ei error.model
51  0.021268669 -0.0015876795 0.00045625   5  NA          <NA>     0.005 -0.003052062        <NA>
52  0.001726581 -0.0109929332 0.00012389   5  NA          <NA>     0.005 -0.003133601        <NA>
53 -0.003482415  0.0003902262 0.00001241   5  NA          <NA>     0.005 -0.003107291        <NA>
54 -0.010112463  0.0047225396 0.00012410   5  NA          <NA>     0.005 -0.002959909        <NA>
55 -0.007467093  0.0036184161 0.00006921   5  NA          <NA>     0.005 -0.002792420        <NA>
56 -0.008373364  0.0172918730 0.00036985   5  NA          <NA>     0.005 -0.002687781        <NA>
57  0.017026402 -0.0008350774 0.00028964   5  NA          <NA>     0.005 -0.002691925        <NA>
58  0.006735039  0.0096698516 0.00013898   5  NA          <NA>     0.005 -0.002702887        <NA>
59 -0.256377756 -0.0120437196 0.06588496   5  NA          <NA>     0.005 -0.001059505        <NA>
60 -0.238420904 -0.0144036386 0.05704192   5  NA          <NA>     0.005 -0.003761101        <NA>
   train.time prop.type propose.time          se         mean
51      0.177 infill_ei        0.144 0.007887601 4.572985e-04
52         NA infill_ei        0.144 0.007626472 8.572543e-05
53         NA infill_ei        0.114 0.007473337 1.775290e-05
54         NA infill_ei        0.107 0.007343511 2.058337e-04
55         NA infill_ei        0.119 0.006878015 1.697411e-04
56         NA infill_ei        0.130 0.006997037 4.759549e-04
57         NA infill_ei        0.134 0.006791627 3.013381e-04
58         NA infill_ei        0.135 0.006652569 1.689551e-04
59         NA infill_ei        0.153 0.041744149 6.548829e-02
60         NA infill_ei        0.149 0.011104461 1.675296e-03
> res$x
$x1
[1] -0.003482415

$x2
[1] 0.0003902262

> res$y
[1] 1.241e-05
```
Note that without the mlrMBO etc. packages installed, you can load the object
but it will not print etc. correctly.

For more information see, the mbo and MBOSingleObjResult in the mlrMBO
documentation: https://cran.r-project.org/web/packages/mlrMBO/mlrMBO.pdf


## Handshake protocol ##
The ME expects to receive the following algorithm parameters:
- max.budget - Maximum total number of objective function evaluations, including both design and iteration evaluations.
- max.iterations - Total number of iterative sampling rounds after the initial design sampling.
- design.size - Total number of design points/evaluations in the initial sampling.
- propose.points - Total number of evaluations within each iteration of the mbo algorithm.
- param.set.file - the file that defines the parameter space, including constraints.

This should be formatted as a string of comma separated key = value pairs. E.g.,:
```R
"max.budget = 60, max.iterations = 5, design.size=10, propose.points=10, param.set.file='../data/parameter_set.R'"
```



## Final protocol ##
The ME pushes the string "DONE" to the OUT queue to indicate that the algorithm has completed. It will subsequently push the message "Look at final_res.Rds for final results." into the OUT queue and complete.


## Testing and running the ME module
The `R/test` directory contains tests for the ME components and for running the ME algorithm with R (i.e., without Swift/T).
* `mlrMBO_utils_tests.R`: unit tests for `R/mlrMBO_utils.R`, which provides R components to the ME (run using the testthat library's `test_file("<path to>/mlrMBO_utils_tests.R")` function)
* `emews_mlrMBO_run.R`: script that provides R implementations for the EQ/R `OUT_put` and `IN_get` calls to be able to run `emews_mlrMBO.R` at smaller scales for testing without Swift/T (run from `R` directory via `source("test/emews_mlrMBO_run.R")`)
* `test_utils_tests.R`: tests for functions in `test/test_utils.R` which are used to make `emews_mlrMBO_run.R` work (run using `test_file("<path to>/test_utils_tests.R")`)


## ME Requirements ##

* Python 2.7
* Swift-t with R enabled - http://swift-lang.org/Swift-T/
* Required R packages:
  * All required R packages can be installed from within R with:
  ```
  install.packages(c("<package name 1>", "<package name 2>", ...)
  ```
  * jsonlite : (https://cran.r-project.org/web/packages/jsonlite/index.html)
  * mlrMBO and dependencies : (https://mlr-org.github.io/mlrMBO/).
  * parallelMap : (https://cran.r-project.org/web/packages/parallelMap/index.html)
  * DiceKriging and dependencies : (https://cran.r-project.org/web/packages/DiceKriging/index.html)
  * rgenoud : (https://cran.r-project.org/web/packages/rgenoud/index.html)
* Compiled EQ/R, instructions in `ext/EQ-R/eqr/COMPILING.txt`
