#from plothelpers import *
from sliders import *
from Z_vsX_vsY_atE import plot as plot0, common_sliders as common_sliders0
from Z_vsX_vsY_atE import nr_axes

from Hamilt_Diagonaliz import common_sliders as common_sliders1



local_sliders = common_sliders0 + common_sliders1 



#===========================================================================#
#
#   Plot
#
#---------------------------------------------------------------------------#



def plot(Ax, zlim=None, opermin=None, opermax=None, **kwargs):



    plot0(Ax, zlim=[opermin,opermax], **kwargs) 

    

        












