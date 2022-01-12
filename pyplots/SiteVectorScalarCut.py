import Plot,Algebra,Utils
from plothelpers import *
from sliders import * 

from Curves_yofx import nr_axes, common_sliders as common_sliders0

from Curves_yofx import plot as plot0

from SiteVector import common_sliders as common_sliders1

common_sliders = common_sliders1 + [sitevectorobs_vminmax, vec2scalar, regions]

add_sliders, read_sliders = addread_sliders(*common_sliders0,
                                            *common_sliders,
                                            choose_energy,
                                            )



#===========================================================================#
#
#   plot
#
#---------------------------------------------------------------------------#

def plot(Ax, get_plotdata, xline=None, yline=None,
                xlim=None, ylim=None,
                sitevectorobsmin=None, sitevectorobsmax=None,
                **kwargs):

    plot0(Ax, get_plotdata, ylim=[sitevectorobsmin, sitevectorobsmax],
            yline=0, **kwargs)








