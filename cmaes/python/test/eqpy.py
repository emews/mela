import threading
import sys
import importlib, traceback

EQPY_ABORT = "EQPY_ABORT"

try:
    import queue as q
except ImportError:
    # queue is Queue in python 2
    import Queue as q

input_q = q.Queue()
output_q = q.Queue()

p = None
aborted = False
wait_info = None

class WaitInfo:

    def __init__(self):
        self.wait = 4

    def getWait(self):
        if self.wait < 60:
            self.wait += 1
        return self.wait

class ThreadRunner(threading.Thread):

    def __init__(self, runnable):
        threading.Thread.__init__(self)
        self.runnable = runnable
        self.exc = None

    def run(self):
        try:
            self.runnable.run()
        except BaseException:
            # tuple of type, value and traceback
            self.exc = traceback.format_exc()

def init(pkg):
    global p, wait_info
    wait_info = WaitInfo()
    imported_pkg = importlib.import_module(pkg)
    p = ThreadRunner(imported_pkg)
    p.start()

def output_q_get():
    global output_q, aborted
    wait = wait_info.getWait()
    # thread's runnable might put work on queue
    # and finish, so it would not longer be alive
    # but something remains on the queue to be pulled
    while p.is_alive() or not output_q.empty():
        try:
            result = output_q.get(True, wait)
            break
        except q.Empty:
            pass
    else:
        # if we haven't yet set the abort flag then
        # return that, otherwise return the formated exception
        if aborted:
            result = p.exc
        else:
            result = EQPY_ABORT
        aborted = True

    return result

def OUT_put(string_params):
    output_q.put(string_params)

def IN_get():
    #global input_q
    result = input_q.get()
    return result
