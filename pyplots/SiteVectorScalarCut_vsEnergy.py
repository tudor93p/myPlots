import Plot,Algebra,Utils
from plothelpers import *
from sliders import *
from Z_vsX_vsEnergy import nr_axes, common_sliders as common_sliders0
from Z_vsX_vsEnergy import plot as plot0
from SiteVectorScalarCut import common_sliders as common_sliders1


add_sliders, read_sliders = addread_sliders(*common_sliders0,
                                            *common_sliders1,
                                            transforms,
                                            smoothen,
                                            regions)



#===========================================================================#
#
#   plot
#
#---------------------------------------------------------------------------#

def plot(Ax, get_plotdata,
                sitevectorobsmin=None, sitevectorobsmax=None,
                **kwargs):

    plot0(Ax, get_plotdata, zlim=[sitevectorobsmin,sitevectorobsmax],
            **kwargs)








