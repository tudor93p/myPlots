import numpy as np
from plothelpers import *
from sliders import *
from VectorField import plot as plot0, common_sliders as common_sliders0
from VectorField import nr_axes



common_sliders = common_sliders0 + [bondvector_observables, choose_energy, obs_index]



#===========================================================================#
#
#   Plot
#
#---------------------------------------------------------------------------#

def plot(Ax, **kwargs):


    plot0(Ax, **kwargs) 

   
    for ax in Ax:
        ax.set_aspect(1)
        












