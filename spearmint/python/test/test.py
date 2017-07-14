# Tests  with eqpy and without swift.
#
# ---------
# * eqpy.input_q.put is equivalent to swift's EQPy_put()
# * eqpy.output_q_get is equivalent to swift's EQPy_get()
# ----------


from __future__ import print_function
import eqpy
import os
import sys

# the objective function -- equivalent to swift running a model / application
def obj(pos):
    return ((pos[0]-5)**2 + (pos[1]-5)**2)

def main():
    home_dir = os.path.abspath(os.path.join(os.getcwd(),os.pardir,os.pardir))
    data_dir = os.path.join(home_dir,'data')
    res_file = os.path.join(data_dir,'results.dat')
    if os.path.exists(res_file):
       thefile = open(res_file, 'w')
       thefile.write("")
       thefile.close()
    # initialize spearmint for emews
    eqpy.init("emews_spearmint")
    # get the handshake -- empty string
    eqpy.output_q_get()
    # send the parameters required to initialize spearmint as a string
    eqpy.input_q.put('1,2')

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
            params = [x.split() for x in params_string.split(';')] 
	    #replace the first item with the objective function, which uses the first 2 x values
	    #replace second item with '0' to match output of the chosen chooser module
	    queue=""
            for x in range(0,len(params)):
                input = [float(z) for z in params[x][2:4]]
		if x==0:
		   queue = queue + str(obj(input)) + ' 0 '
		else:
		   queue = queue + ';' + str(obj(input)) + ' 0 '
		for p in params[x]:
		   queue = queue + str(p) + " "
            # pass the results from the objective function (queue) back to spearmint
            eqpy.input_q.put(queue)

    # gets the final "see X for history" message
    print(eqpy.output_q_get())

    # load the history file for testing purposes
    # typically a swift script wouldn't do anything with this
    with open(res_file,'r') as f_in:
        history = f_in.readlines()
    assert history[0] == '50.0 0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0  \n'
    print("PASSED")

if __name__ == '__main__':
    print(sys.argv[0])
    main()
