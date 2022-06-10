from plothelpers import *
from sliders import *
from Z_vsX_vsY import plot as plot0, common_sliders as common_sliders0
from Z_vsX_vsY import nr_axes



common_sliders =   common_sliders0 + [energy_zoom]


add_sliders, read_sliders = addread_sliders(*common_sliders, smoothen)



#===========================================================================#
#
#   Plot
#
#---------------------------------------------------------------------------#



def plot(Ax, get_plotdata, enlim=None, Energy=None, **kwargs):


    plot0(Ax, get_plotdata, ylabel="Energy",
            ylim=enlim, yline=Energy, Energy=Energy, **kwargs) 

    

        












