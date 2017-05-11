from __future__ import print_function

import cmaes as cm
import eqpy
import json

# EQ/Py entry function: called when EQPy is
# initialized in the swift script.
def run():
    # handshake
    eqpy.OUT_put("")

    # formatted as a json string
    cmaes_params = eqpy.IN_get()
    param_obj = json.loads(cmaes_params)
    # create and initliaze a CMAES object from the parameters
    cmaes = cm.CMAES(param_obj['n_param'], param_obj['n_child'], param_obj['n_surv'],
        param_obj['sig'])
    # TODO move these into constructor ??
    cmaes.init_params(param_obj['init_vals'])
    cmaes.init_bounds(param_obj['init_bounds'])

    max_iter = param_obj['max_iter']
    param_string = ""
    for i in range(max_iter):
        # list of lists where the nth element of each list when
        # taken together is a parameter set
        model_params = cmaes.get_params()
        # create a list of lists where each element is a parameter set
        model_params = zip(*model_params)
        #print(model_params[0:2])
        # for each parameter set convert the parameters to a string and separate
        # them with a ",". Join all the individual parmaeter set strings together
        # separated with a ";"
        param_string = ";".join([",".join([str(param) for param in p]) for p in model_params])
        # send the param_string back to swift
        eqpy.OUT_put(param_string)
        # objs_string should be a ";" separated list of floats
        objs_string = eqpy.IN_get()
        # create a python list of floats from objs_string by spliting and
        # converting the string values to floats
        objs_list = [float(x) for x in objs_string.split(";")]
        # pass the list of float to cmaes for it to produce the next round
        # of parameters
        cmaes.update_state(objs_list)

    eqpy.OUT_put("DONE")
    eqpy.OUT_put(param_string)
    # TODO final output something more complex
