#from plothelpers import *

from sliders import *

from Scatter_vsEnergy import nr_axes 

from Scatter_vsEnergy import common_sliders as common_sliders0, plot as plot0


common_sliders = [operators, oper_vminmax, choose_k, obs_index]


local_sliders = common_sliders0 + common_sliders 



#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#


def plot(Ax, get_plotdata,  
                k=None, xline=None, opermin=None, opermax=None, **kwargs):

    plot0(Ax, get_plotdata, xline=k, zlim=[opermin,opermax], 
            opermin=opermin, opermax=opermax,
            **kwargs)

    










