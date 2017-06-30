# A CMA-ES based EMEWS model exploration (ME) module #

(Adapted from CMA-ES Swift/T workflow developed by Daniel Reid.)

## ME algorithm details ##

CMA-ES is an evolutionary optimization scheme which uses the covariance matrix of the children at each generation to create the next set of children.   The algorithm is initialized with `init_params` as the mean of the first generation.  It is often necessary to place boundaries on the space which the optimization algorithm can explore.  Optionally, bounds can be specified.  This can optionally constrain the upper or lower bound of each dimension which is being optimized. At each iteration, `n_child` children are spawned based on the covariance matrix, and the best `n_surv` are used to seed the next generation.  The initial spread of the distribution can be controlled with `sig`.

## ME Final Output file: cmaes_history.json

At the end of its run, `emews_cmaes` produces a file named `cmaes_history.json`
that contains the history of the CMA-ES model exploration. Typically that file
is written to the directory specified by the `TURBINE_OUTPUT` environment variable
or in the current working directory if `TURBINE_OUTPUT` is not specified.

The model exploration history is written out in JSON format as a JSON
array of length `max_iter`. The *n*-th element of the array contains the
data for the *n*-th iteration. Each element of the array contains a
dictionary with two elements: the `me_parameters` and the `model_result`.
The `me_parameters` specifies the model parameters produced by the CMA-ES
algorithm and `model_result` specifies the results of running the model
with those parameters. For example,

```javascript
[
   ...
   {
       "me_parameters": [
           [
               24.66299068887551,
               94.781402836274
           ],
           [
               24.66299715432471,
               94.78142617556536
           ],
           [
               24.662976073843083,
               94.78141061276041
           ],
           [
               24.662993706845448,
               94.78143212648598
           ]
       ],
       "model_result": [
           51.4522893642,
           51.4523064937,
           51.4523033295,
           51.4523133708
       ]
   }
   ...
]
```

The values within the dictionary are ordered such that the *n*-th element
of the `model_result` list is the result of running the *n*-th parameter set
of the `me_parameters` list.

By default the entire history is written out. If the optional `history` initialization
parameter (see below) is false, only the data from the final iteration will
be written out.

## Handshake protocol ##
`emews_cmaes` begins the handshake by inserting an empty string into its
output queue, expecting the Swift-t workflow to retrieve it with an
`EQPy_get` call. `emews_cmaes` then expects to receive the following
initialization parameters from the Swift-t workflow (inserted with an
`EQPy_put` call).

* **init_params**: An initial parameter set.  Should be of length `n_param`.
* **bounds**: A list of upper and lower boundaries for each parameter.  Must be a list of tuples as (low bound, high bound).  If a parameter is unbounded, enter `None` for that bound.
* **n_child**: Number of children to spawn at each iteration.
* **n_surv**: How many children to use to seed the next generation.  The n_surv which have the lowest objective function are used.
* **sig**: Describes the initial spread of the parameters.
* **max_iter**: The number of iterations to perform. `emews_cmaes` will produce
 `n_child` number of parameter sets per iteration for a total number of
 evalutions equal to `n_child` \* `max_iter`.
* **history** (optional): if False, then only the final iteration will be
written out, otherwise the complete history is written. Defaults to True.


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
has completed. It will subsequently push a message string indicating where the
model exploration history (see above) has been written out.


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
