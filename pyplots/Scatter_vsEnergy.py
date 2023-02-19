import Plot, Algebra, Utils
import numpy as np
from plothelpers import *
from sliders import *

from Scatter import nr_axes 

from Scatter import common_sliders as common_sliders0, plot as plot0


common_sliders1 = [energy_zoom]

common_sliders = common_sliders0 + common_sliders1




#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#


def plot(Ax, get_plotdata,  
            Energy=None, yline=None, enlim=None, ylim=None,
            **kwargs):

    plot0(Ax, get_plotdata, yline=Energy, ylim=enlim, **kwargs) 
    










