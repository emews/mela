# A CMAES based EMEWS model exploration (ME) module #

TODO: acknowlege Daniel Reid


## ME algorithm details ##

TODO

## ME Final Output ##

TODO -- currently the last set of parameters

## Handshake protocol ##
`emews_cmaes` begins the handshake by inserting an empty string into its
output queue, expecting the Swift-t workflow to retrieve it with an
`EQPy_get` call. `emews_cmaes` then expects to receive the following
initialization parameters from the Swift-t workflow (inserted with an
`EQPy_put` call).

* **init_params**: TODO - an initial parameter set.
* **bounds**: TODO - the upper and lower bounds for each parameters.
* **n_child**: the number of parameter sets to produce per iteration.
* **n_surv**: TODO
* **sig**: TODO
* **max_iter**: the number of iterations to perform. `emews_cmaes` will produce
 _n_child_ number of parameter sets per iteration for a total number of
 evalutions equal to *n_child* \* *max_iter*.


These should be formatted as JSON string. For example,

```javascript
{
  'init_params': [25, 95],
  'bounds': [[0, 100], [0, 110]],
  'n_child': 250,
  'n_surv': 10,
  'sig': 0.1
  'max_iter': 200
}
```

**Note** that `init_params` is a JSON array and that `bounds` is an array of
arrays where nested list element *n* is the lower and upper bound for the
the corresponding *n*-th parameter. In the above, the initial parameter set is
`25, 95` and the first parameter has range of *0 - 100* while the second a
range of *0 - 110*.

## Final protocol ##
The ME pushes the string "DONE" to the OUT queue to indicate that the algorithm
has completed. It will subsequently push the final set set of parameters.

## Testing and running the ME module
The `test` directory contains a test (`test.py`) for `emews_cmaes` that runs
the ME algorithm with python and eqpy (included in the `test` directory), but
without Swift/T. To run the test, run the `run_test.sh` bash script in the
`test` directory.

## ME Requirements ##

* Python 2.7 or 3
* numpy
* Swift-t with Python enabled - http://swift-lang.org/Swift-T/
* EQ-Py Swift-t extension installed - see the EMEWS templates section in the
EMEWS tutorial (http://www.mcs.anl.gov/~emews/tutorial/).
