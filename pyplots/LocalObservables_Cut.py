from Curves_yofx import plot as plot0

from Curves_yofx import common_sliders as common_sliders0, nr_axes

from LocalObservables import common_sliders as common_sliders1

from sliders import *


add_sliders, read_sliders = addread_sliders(
                                    *common_sliders0,
                                    *common_sliders1,
#                                    *common_sliders,
                                    choose_energy,
                                    regions,
                                    )



def plot(Ax, get_plotdata, 
                lobsmin=None, lobsmax=None, ylim=None, **kwargs):

    plot0(Ax, get_plotdata, ylim=[lobsmin,lobsmax], **kwargs)
            

    
    




