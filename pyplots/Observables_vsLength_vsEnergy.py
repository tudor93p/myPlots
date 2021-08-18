from Observables_vsX_vsEnergy import plot as plot0
from Observables_vsX_vsEnergy import common_sliders, nr_axes
from sliders import *

add_sliders,read_sliders = addread_sliders(*common_sliders)

def plot(Ax, get_plotdata, length=None, xline=None, **kwargs):


    plot0(Ax, get_plotdata, xline=length, **kwargs)


    
    
    




