# An mlrMBO based EMEWS model exploration (ME) module #


## ME algorithm details ##
The R-based ME algorithm attempts to minimize an objective function for a parameter space defined using the ParamHelpers library.

 For example,
```R
  par.set = makeParamSet(
    makeNumericParam("x1", lower = -5, upper = 5),
    makeNumericParam("x2", lower = -10, upper = 20))
```
This defines the two dimensional space `(x1,x2)` with the specified limits.  See http://berndbischl.github.io/ParamHelpers/man/makeParamSet.html for more details on defining parameter sets.

The algorithm makes use of existing capabilities from mlrMBO:
* **expected improvement** for the infill criterion
* **constant liar** for multi-point proposals

The example uses **multi-point proposals** for concurrency in the iterative steps, defined via a `pp=<number of proposed points>` passed in via the [handshake protocol](#handshake-protocol). See https://mlr-org.github.io/mlrMBO/articles/supplementary/parallelization.html for more information on parallelization in mlrMBO.

The maximum algorithm iteration is specified via a `it=<number of max iterations>` argument, also defined via the [handshake protocol](#handshake-protocol).

### ME output file: final_res.Rds ###
mlrMBO's mbo function produces a MBOSingleObjResult object. That object is
saved to the file system either to the working directory or, if within an EMEWS workflow, to the experiment directory as `final_res.Rds` and can be loaded within an R session using `readRDS("<path to>/final_res.Rds")`. The results contain the final best parameter values (the 'x' attribute) and associated metadata about the parameter evaluations. Sample R
session:

```R
> res <- readRDS("final_res.Rds")
> res
Recommended parameters:
x1=-0.0666; x2=-0.0653
Objective: y = 0.009

Optimization path
8 + 10 entries in total, displaying last 10 (or less):
            x1          x2            y dob eol error.message exec.time          ei error.model train.time
9   0.45059800  0.18132741  0.235918185   1  NA          <NA>     0.000 -12.7373597        <NA>      0.091
10 -1.58082671 -2.34834688  8.013746142   1  NA          <NA>     0.000  -6.8104158        <NA>         NA
11 -0.65688018 -0.33727720  0.545247477   2  NA          <NA>     0.000  -1.7456097        <NA>      0.048
12 -0.40940021  0.94706024  1.064531638   2  NA          <NA>     0.000  -1.3855241        <NA>         NA
13  0.16459938 -1.12695820  1.297127739   3  NA          <NA>     0.000  -0.9964390        <NA>      0.056
14  1.42611610 -0.69637200  2.518741101   3  NA          <NA>     0.000  -0.6839068        <NA>         NA
15 -0.06663489 -0.06527286  0.008700755   4  NA          <NA>     0.001  -0.4316389        <NA>      0.055
16 -1.18530439  0.35496120  1.530943945   4  NA          <NA>     0.001  -0.2697869        <NA>         NA
17  4.99974102 -0.47807419 25.225965199   5  NA          <NA>     0.001  -0.1285891        <NA>      0.057
18  3.92648006  0.10692619 15.428678884   5  NA          <NA>     0.001  -0.9169606        <NA>         NA
   prop.type propose.time         se        mean
9  infill_ei        0.076 20.9490796  3.67770913
10 infill_ei        0.160 20.0269748 13.81438911
11 infill_ei        0.068  4.2506720  0.13715969
12 infill_ei        0.063  3.8944527  0.58464278
13 infill_ei        0.073  3.3999417  1.02933270
14 infill_ei        0.078  3.7482281  2.30188392
15 infill_ei        0.069  0.7848909  0.02200744
16 infill_ei        0.174  1.7664727  1.40237084
17 infill_ei        0.074 13.7356711 26.97661021
18 infill_ei        0.073  4.0697096  1.69760612
> res$x
$x1
[1] -0.06663489

$x2
[1] -0.06527286

> res$y
[1] 0.008700755
```
Note that without the mlrMBO etc. packages installed, you can load the object
but it will not print etc. correctly.

For more information see, the mbo and MBOSingleObjResult in the mlrMBO
documentation: https://cran.r-project.org/web/packages/mlrMBO/mlrMBO.pdf


## Handshake protocol ##
The ME expects to receive the number of proposed points (`pp`) and the maximum number of algorithm iterations (`it`) when it calls `IN_get()` for the first time. This should be formatted as a string of comma separated key = value pairs. E.g.,:
```R
"pp = 3, it = 5"
```


## Final protocol ##
The ME pushes the string "DONE" to the OUT queue to indicate that the algorithm has completed. It will subsequently push the message "Look at final_res.Rds for final results." into the OUT queue and complete.


## Testing and running the ME module
The `test` directory contains tests for the ME components and for running the ME algorithm with R (i.e., without Swift/T).
* `mlrMBO_utils_tests.R`: unit tests for `mlrMBO_utils.R`, which provides R components to the ME (run using the testthat library's `test_file("<path to>/mlrMBO_utils_tests.R")` function)
* `emews_mlrMBO_run.R`: script that provides R implementations for the EQ/R `OUT_put` and `IN_get` calls to be able to run `emews_mlrMBO.R` at smaller scales for testing without Swift/T (run from top directory via `source("test/simple_mlrMBO_run_test.R")`)
* `test_utils_tests.R`: tests for functions in `test/test_utils.R` which are used to make `emews_mlrMBO_run.R` work (run using `test_file("<path to>/test_utils_tests.R")`)


## ME Requirements ##

* Python 2.7
* Swift-t with R enabled - http://swift-lang.org/Swift-T/
* Required R packages:
  * All required R packages can be installed from within R with:
  ```
  install.packages(c("<package name 1>", "<package name 2>", ...)
  ```
  * mlrMBO and dependencies : (https://mlr-org.github.io/mlrMBO/).
  * parallelMap : (https://cran.r-project.org/web/packages/parallelMap/index.html)
  * DiceKriging and dependencies : (https://cran.r-project.org/web/packages/DiceKriging/index.html)
  * rgenoud : (https://cran.r-project.org/web/packages/rgenoud/index.html)
* Compiled EQ/R, instructions in `ext/EQ-R/eqr/COMPILING.txt`
