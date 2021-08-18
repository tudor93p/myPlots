from Curves_yofx import plot as plot0
from Curves_yofx import common_sliders, nr_axes
from sliders import *

add_sliders,read_sliders = addread_sliders(*common_sliders)


def plot(Ax, get_plotdata, length=None, xline=None, **kwargs):

    plot0(Ax, get_plotdata, xline=length, **kwargs)


    
    
    




