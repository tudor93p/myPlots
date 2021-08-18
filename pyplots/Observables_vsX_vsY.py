from plothelpers import *
from sliders import *
from Z_vsX_vsY import plot as plot0, common_sliders as common_sliders0
from Z_vsX_vsY import nr_axes



common_sliders = common_sliders0 + [observables, obs_index, obs_vminmax]

add_sliders, read_sliders = addread_sliders(*common_sliders)


#===========================================================================#
#
#   Plot
#
#---------------------------------------------------------------------------#



def plot(Ax, get_plotdata, zlim=None, obsmin=None, obsmax=None, **kwargs):


    plot0(Ax, get_plotdata, zlim=[obsmin,obsmax], **kwargs) 

    

        












