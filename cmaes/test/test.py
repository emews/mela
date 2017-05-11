# Tests emews_cmaes with eqpy and without swift.
#
# ---------
# * eqpy.input_q.put is equivalent to swift's EQPy_put()
# * eqpy.output_q_get is equivalent to swift's EQPy_get()
# ----------


from __future__ import print_function
import json, eqpy

# the objective function -- equivalent to swift running a model / application
def obj(pos):
    return ((pos[0]-50)**2 + (pos[1]-50)**2)**0.5

def main():
    # initialize cmaes for emews
    eqpy.init("emews_cmaes")
    # get the handshake -- empty string
    eqpy.output_q_get()
    # send the parameters required to initialize cmaes as a
    # json string
    max_iter = 200
    params = {'n_param' : 2, 'n_child' : 250, 'n_surv' : 10, 'sig' : 0.1,
              'max_iter' : max_iter, 'init_vals' : [25, 95], 'init_bounds' : [(0, 100), (0, 100)]}
    eqpy.input_q.put(json.dumps(params))

    # count the number of iteations to make sure
    # 'max_iter' iterations are performed
    iter_count = 0
    while True:
        params_string = eqpy.output_q_get()
        if params_string == "DONE":
            break
        elif params_string == "EQPY_ABORT":
            # print the python error
            print(eqpy.output_q_get())
        else:
            iter_count += 1
            # convert the parameter string into a list of lists where the
            # nested list are the parameter sets
            params = [[float(y) for y in x.split(',')] for x in params_string.split(';')]
            # pass each parameter set p to our objective function,
            # convert the result to a string, and make list of those strings
            objs = [str(obj(p)) for p in params]
            # join the elements in the objs list of string together with ";" as
            # a separator.
            objs_string = ";".join(objs)
            # pass the results from the objective function (objs_string) back
            # to cmaes
            eqpy.input_q.put(objs_string)

    # get the final set of parameters
    final_param_string = eqpy.output_q_get()
    params_list = [[float(y) for y in x.split(',')] for x in final_param_string.split(';')]
    p = params_list[3]
    assert p[0] > 49 and p[0] < 51 and p[1] > 49 and p[1] < 51
    assert iter_count == max_iter
    print("PASSED")

if __name__ == '__main__':
    main()
