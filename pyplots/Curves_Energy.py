from Curves_yofx import plot as plot0

from Curves_yofx import common_sliders as common_sliders0, nr_axes

from sliders import *


common_sliders = common_sliders0 + [energy_zoom]




def plot(Ax, Energy=None, yline=None, ylabel="Energy",
                    ylim=None, enlim=None, **kwargs):

    plot0(Ax, yline=Energy, ylim=enlim, ylabel=ylabel, **kwargs)


    
    
    




