from plothelpers import *
from sliders import * 

from Scatter import nr_axes, common_sliders as common_sliders0

from Scatter import plot as plot0

from Observables import common_sliders as common_sliders1

common_sliders = common_sliders1 + [choose_energy ]


add_sliders, read_sliders = addread_sliders(*common_sliders)
        



#===========================================================================#
#
#   plot
#
#---------------------------------------------------------------------------#

def plot(Ax, get_plotdata, yline=None, obsmin=None,obsmax=None,
                ylim=None, **kwargs):

    plot0(Ax, get_plotdata, ylim=[obsmin,obsmax],
            yline=0, **kwargs)








