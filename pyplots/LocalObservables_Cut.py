from Curves_yofx_atE import plot as plot0

from Curves_yofx_atE import common_sliders as common_sliders0, nr_axes

from LocalObservables import common_sliders as common_sliders1

from sliders import *


local_sliders = common_sliders0 + common_sliders1 + [regions]




def plot(Ax, lobsmin=None, lobsmax=None, ylim=None, **kwargs):

    plot0(Ax, ylim=[lobsmin,lobsmax], **kwargs)
            

    
    




