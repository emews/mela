import numpy as np
import math, copy

class CMAES:
    def __init__(self, params, bounds, nChild, nSurv, sig):
#these are all things we know on initialization - nparam is just #bonds or #bonds+#angles
        self.nParam = len(params)
        self.nChild = nChild
        self.nSurv = nSurv
        self.sig = sig
#constants
        self.cc = 4.0 / (self.nParam+4)
        self.acov = 1.0 / self.nSurv
        self.ccov = (2*self.acov)/(self.nParam+2**0.5)**2 + (1-self.acov)*min(1, (2*self.nSurv-1) / ((self.nParam+2)**2 + self.nSurv))
        self.chiN = self.nParam**0.5 * (1 - 1.0/(4*self.nParam) + 1.0/(21*self.nParam**2))
        #print self.ccov
#for csif I had self.nParam + 2 in test.py - this was a typo
        self.csig = 4.0 / (self.nParam+1) #when this is self.nParam+2, it works great in 1 dim
        self.dsig = 1.0/sig + 1
        self.C = np.matrix(np.identity(self.nParam))
        self.D = np.matrix(np.identity(self.nParam))
        self.B = np.matrix(np.identity(self.nParam))

        self.Z = None
        self.pc = np.matrix(np.zeros((self.nParam, 1)))
        self.psig = np.matrix(np.zeros((self.nParam, 1)))
        self.Xu = None
#number of times nextParams has been called
        self.nIter = 0
#the parameters that I last sent back to swift/t
        self.workingParams = []
        self.objBest = None
        self.bounds = None

        if isinstance(params, str):
            params = eval(params)
        self.Xu = np.array(params)

        if isinstance(bounds, str):
            bounds = eval(bounds)
        if len(bounds) != self.nParam:
            raise ValueError("Length of bounds and number of params are not equal.")

        assert(len(bounds) == self.nParam)
        self.bounds = bounds

    def get_params(self):
        """
            returns a string rep of list of self.nParam lists, each of which
            has self.nChild parameters. The nth element of each list taken
            together is a parameter set.
        """

        self.Z = np.matrix([[np.random.normal() for i in range(self.nChild)] for j in range(self.nParam)])
        if self.nIter != 0:
            XuWorking = []
            for i in range(self.nParam):
                valsBestForParam = []
                for best in self.objBest:
                    idx = best[0]
                    valsBestForParam.append(self.workingParams[i][idx])
                XuWorking.append(np.average(valsBestForParam))
            self.Xu = np.array(XuWorking)

#working params ordered as [paramIdx, childIdx]
        self.workingParams = []
        #print self.sig * self.B * self.D
        processedNoise = self.sig * self.B * self.D * self.Z
        for i in range(self.nParam):
            valsForParam = []
            for j in range(self.nChild):
                val = self.Xu[i] + processedNoise[i, j]
                if val < self.bounds[i][0]:
                    val = self.bounds[i][0]
                elif val > self.bounds[i][1]:
                    val = self.bounds[i][1]
                valsForParam.append(val)
            self.workingParams.append(valsForParam)
        self.nIter += 1
        return copy.deepcopy(self.workingParams)

    def update_state(self, objectives):
        if isinstance(objectives, str):
            objectives = eval(objectives)
        #print objectives


        objZip = zip(range(len(objectives)), objectives)
        objZipSort = sorted(objZip, key=lambda x: x[1])
        self.objBest = objZipSort[:self.nSurv]

        Zu = np.matrix(np.zeros((self.nParam, 1)))
        for best in self.objBest:
            idx = best[0]
            Zu += self.Z[:, idx]
        Zu /= self.nSurv

        Zsum = np.matrix(np.zeros((self.nParam, self.nParam)))

        for best in self.objBest:
            idx = best[0]
            Zsum += self.Z[:, idx] * self.Z[:, idx].transpose()
        Zsum /= self.nSurv

        Zmod = self.B * self.D * Zsum * self.D.transpose() * self.B.transpose()

        self.pc = (1-self.cc)*self.pc + (self.cc*(2-self.cc)*self.nSurv)**0.5 * (self.B*self.D*Zu)

        self.C = (1-self.ccov)*self.C + self.ccov*(self.acov*self.pc*self.pc.transpose() + (1-self.acov)*Zmod)
        #print self.C

        self.psig = (1-self.csig)*self.psig + (self.csig * (2-self.csig) * self.nSurv)**0.5 * self.B*Zu


        self.sig = self.sig*math.exp((np.linalg.norm(self.psig) - self.chiN) / (self.dsig * self.chiN))

        Dproc, Bproc = np.linalg.eig(self.C)
        self.D = np.matrix(np.identity(self.nParam))
        for i, d in enumerate(Dproc):
            self.D[i, i] = d**0.5
        #DOES dsig EVER CHANGE?
        self.B = Bproc
