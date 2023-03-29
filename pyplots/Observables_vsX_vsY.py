from sliders import *
from Z_vsX_vsY_atE import plot as plot0, common_sliders as common_sliders0
from Z_vsX_vsY_atE import nr_axes



common_sliders = common_sliders0 + [observables, obs_index, obs_vminmax]



#===========================================================================#
#
#   Plot
#
#---------------------------------------------------------------------------#



def plot(Ax, zlim=None, obsmin=None, obsmax=None, **kwargs):


    plot0(Ax, zlim=[obsmin,obsmax], **kwargs) 

    

        












