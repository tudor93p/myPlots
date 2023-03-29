from plothelpers import *

from sliders import *

from Observables_vsX_vsY import nr_axes, plot as plot0

from Observables_vsX_vsY import common_sliders as common_sliders0



common_sliders = common_sliders0 + [energy_zoom]



#===========================================================================#
#
#   Plot
#
#---------------------------------------------------------------------------#



def plot(Ax, enlim=None, yline=None, ylim=None, Energy=None, **kwargs):


    plot0(Ax, ylabel="Energy", ylim=enlim, Energy=Energy, yline=Energy, **kwargs) 

        












