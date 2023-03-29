from Observables_vsX_vsY import plot as plot0
from Observables_vsX_vsY import common_sliders, nr_axes
from sliders import *

local_sliders = common_sliders + [choose_energy]


def plot(Ax, width=None, length=None, 
                yline=None, xline=None, **kwargs):

    plot0(Ax, yline=width, xline=length, **kwargs)


    
    
    




