from __future__ import print_function

import cmaes as cm
import eqpy
import json
import os


# EQ/Py entry function: called when EQPy is
# initialized in the swift script.
def run():
    # handshake
    eqpy.OUT_put("")

    # formatted as a json string
    cmaes_params = eqpy.IN_get()
    param_obj = json.loads(cmaes_params)
    # create and initliaze a CMAES object from the parameters
    cmaes = cm.CMAES(param_obj['init_params'], param_obj['bounds'], param_obj['n_child'], param_obj['n_surv'],
        param_obj['sig'])

    history = True
    if 'history' in param_obj and not param_obj['history']:
        history = False

    log = []
    io_dict = {}

    if not history:
        log.append(io_dict)

    max_iter = param_obj['max_iter']
    for i in range(max_iter):
        # list of lists where the nth element of each list when
        # taken together is a parameter set
        model_params = cmaes.get_params()
        # create a list of lists where each element is a parameter set
        model_params = zip(*model_params)
        io_dict['me_parameters'] = list(model_params)

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
        io_dict['model_result'] = list(objs_list)

        # pass the list of float to cmaes for it to produce the next round
        # of parameters
        cmaes.update_state(objs_list)

        # reset the loggging dictionary for the next round
        # don't append if we are not collecting the history
        if history:
            log.append(io_dict)
        else:
            log[0] = io_dict
        io_dict = {}


    eqpy.OUT_put("DONE")

    # emews should set this var
    out_dir = os.environ.get('TURBINE_OUTPUT')
    if out_dir is None:
        out_dir = '.'
    # write histor to a file
    f = os.path.abspath("{}/cmaes_history.json".format(out_dir))
    with open(f, "w") as f_out:
        # thi
        json.dump(log, f_out, separators=(',', ':'))

    eqpy.OUT_put("See {} for model exploration history".format(f))
