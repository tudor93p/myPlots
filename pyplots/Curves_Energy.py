from Curves_yofx import plot as plot0

from Curves_yofx import common_sliders as common_sliders0, nr_axes

from sliders import *


common_sliders = common_sliders0 + [energy_zoom]

add_sliders, read_sliders = addread_sliders(*common_sliders,
                                            )



def plot(Ax, get_plotdata, Energy=None, yline=None, 
                    ylim=None, enlim=None, **kwargs):

    plot0(Ax, get_plotdata, 
            yline=Energy, ylim=enlim, ylabel="Energy", **kwargs)


    
    
    




