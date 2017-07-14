# A Spearmint-based EMEWS model exploration (ME) module

This repository integrates the Spearmint code method--specifically, the Spearmint-lite version-- with EMEWS.

## ME Algorithm Details

Spearmint is a package developed by Jasper Snoek, according to the algorithms outlined in the paper:

Practical Bayesian Optimization of Machine Learning Algorithms
Jasper Snoek, Hugo Larochelle and Ryan P. Adams
Advances in Neural Information Processing Systems, 2012


The python-based ME algorithm models a complex simulator or learning algorithm's performance (output) as a sample from a Gassian Process (GP). The model's hyperparameters are then varied and, based upon the acquisition function chosen, a single Bayesian optimization is run to determine the next best set of data points for evaluation. Each subsequent run of the algorithm then leverages the previous data points and their evaluations. 

## Configuration File
For `emew_spearmint` to run, a json configuration file (`config.json`) describing the domain of the optimized parameters is expected. Within the provided code in this repositiory, this file is expected to reside in the `data` folder within the EMEWS structure file.

The configuration file contains a list of 'variables', which specifies the name, type and size of the variables you wish to optimize over. Each variable must be either a FLOAT, INT or ENUM type, corresponding to continuous real valued parameters, integer sequences and categorical variables respectively. MAX and MIN specify the bounds of the variables over which to optimize and SIZE is the number of variables of this type with these bounds. 

For example,

```
{
"X" : {
  "name":"X",
  "type":"float",
  "min":0,
  "max":7000,
  "size":8
}
}
```


## Handshake Protocol
`emews_spearmint` begins the handshake by inserting a string "Params" into its output queue, expecting the Swift-t workflow to retrieve it with an `EQPy_get` call. `emews_spearmint` then expects to receive the following initialization parameters from the Swift-t workflow (inserted with an `EQPy_put` call):

* **Total number of Trials (-nt):** the number of iterations to perform
* **Number of Data Points (-np):** the number of data points spearmint should suggest in each loop

The ME expects to receive these parameters respectively when it calls `IN_get()` for the first time in the following format:

```
'2,3'
```

## Final Protocol
The ME pushes the string "DONE" to the OUT queue to indicate that the algorithm has completed. It will subsequently push the message "Refer to results.dat file in data directory" into the OUT queue and complete.


## Results
The results of this ME code will be placed in a `results.dat` file located in the EMEWS `data` directory. The `results.dat` will contain a white-space delimited line for each experiment, of the format: `<result> <time-taken> <list of parameters in the same order as config.json>`
 
 
## Testing ME model

The `test` directory contains a test (`test.py`) for `emews_spearmint` that runs the ME algorithm with python and eqpy (included in the `test` directory), but without Swift/T. To run the test, run the `run_test.sh` bash script in the test directory.


## ME Requirements

This package requires the following:
 
* Python 2.7
* Swift-t with python enabled - http://swift-lang.org/Swift-T/
* Spearmint with Spearmint-lite included - https://github.com/JasperSnoek/spearmint
* EQ-Py Swift-t extension installed - see the EMEWS templates section in the EMEWS tutorial (http://www.mcs.anl.gov/~emews/tutorial/).


## Assumptions

The provided code in this repository contains the following assumptions, which can be changed via the `run` function's arguments to the `main_controller()` method: 

* The `method` argument specifies the chooser module (acquisition function) as the `GPEIOptChooser1`, which first samples from a dense grid on the unit hypercube and then the best candidates are optimized via Expected Improvement
* The `method-args` argument is left blank, which means we are assuming that the function of interest is not deterministic (i.e. contains noise)

For further details, refer to the Spearmint README file: https://github.com/JasperSnoek/spearmint
