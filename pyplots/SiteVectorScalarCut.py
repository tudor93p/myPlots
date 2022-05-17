#from plothelpers import *
from sliders import * 

from SiteVectorScalarCut_atE import nr_axes 
from SiteVectorScalarCut_atE import common_sliders as common_sliders0
from SiteVectorScalarCut_atE import plot as plot0

from SiteVector import common_sliders as common_sliders1

common_sliders = common_sliders1 + [sitevectorobs_vminmax]

add_sliders, read_sliders = addread_sliders(*common_sliders0,
                                            *common_sliders,
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








