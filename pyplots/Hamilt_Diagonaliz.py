import numpy as np
import Plot, Algebra, Utils
from plothelpers import *
from sliders import *

from Scatter_vsEnergy import nr_axes 

from Scatter_vsEnergy import common_sliders as common_sliders0, plot as plot0


common_sliders1 = [ operators, oper_vminmax, pick_systems, choose_k]


add_sliders, read_sliders = addread_sliders(*common_sliders1,
                                            *common_sliders0
                                            )


#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#


def plot(Ax, get_plotdata,  
                k=None, xline=None, opermin=None, opermax=None, **kwargs):

    plot0(Ax, get_plotdata, xline=k, zlim=[opermin,opermax], **kwargs)

    










