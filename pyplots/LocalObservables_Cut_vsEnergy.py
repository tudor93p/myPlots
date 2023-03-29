from Z_vsX_vsEnergy import plot as plot0

from Z_vsX_vsEnergy import common_sliders as common_sliders0, nr_axes

from LocalObservables import common_sliders as common_sliders1

from sliders import *


local_sliders = common_sliders0 + common_sliders1 + [regions, transforms, smoothen]



def plot(Ax, lobsmin=None, lobsmax=None, 
                            zmin=None, zmax=None, **kwargs):

    plot0(Ax, zmin=lobsmin, zmax=lobsmax, **kwargs)
            

    
    




