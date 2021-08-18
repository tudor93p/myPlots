from Observables_vsX_vsY import plot as plot0
from Observables_vsX_vsY import common_sliders, nr_axes
from sliders import *


add_sliders,read_sliders = addread_sliders(*common_sliders, choose_energy)

def plot(Ax, get_plotdata, width=None, length=None, 
                yline=None, xline=None, **kwargs):

    plot0(Ax, get_plotdata, yline=width, xline=length, **kwargs)


    
    
    




