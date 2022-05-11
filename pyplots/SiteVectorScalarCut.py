#from plothelpers import *
from sliders import * 

from SiteVectorScalarCut0 import nr_axes 
from SiteVectorScalarCut0 import common_sliders as common_sliders0
from SiteVectorScalarCut0 import plot as plot0

from SiteVector import common_sliders as common_sliders1

common_sliders = common_sliders1 + [sitevectorobs_vminmax]

add_sliders, read_sliders = addread_sliders(*common_sliders0,
                                            *common_sliders,
                                            choose_energy,
                                            )



#===========================================================================#
#
#   plot
#
#---------------------------------------------------------------------------#

def plot(Ax, get_plotdata, #xline=None, yline=None,
                #xlim=None, 
                ylim=None,
                sitevectorobsmin=None, sitevectorobsmax=None,
                **kwargs):

    plot0(Ax, get_plotdata, ylim=[sitevectorobsmin, sitevectorobsmax],
            **kwargs)








