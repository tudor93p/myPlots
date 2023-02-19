from plothelpers import *
from sliders import * 

from Scatter import nr_axes, common_sliders as common_sliders0

from Scatter import plot as plot0

from Observables import common_sliders as common_sliders1

common_sliders = common_sliders1 + [choose_energy ]


        



#===========================================================================#
#
#   plot
#
#---------------------------------------------------------------------------#

def plot(Ax, get_plotdata, yline=None, obsmin=None,obsmax=None,
                ylim=None, **kwargs):

    plot0(Ax, get_plotdata, ylim=[obsmin,obsmax],
            yline=0, **kwargs)








