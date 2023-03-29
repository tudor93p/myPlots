from sliders import * 

from SiteVectorScalarCut import common_sliders as common_sliders0

from Z_vsX_vsEnergy import common_sliders as common_sliders1

from Z_vsX_vsEnergy import nr_axes  

from Z_vsX_vsEnergy import plot as plot0 



local_sliders = common_sliders0 + common_sliders1 



#===========================================================================#
#
#   plot
#
#---------------------------------------------------------------------------#

def plot(Ax, sitevectorobsmin=None, sitevectorobsmax=None, **kwargs):

    plot0(Ax, zlim=[sitevectorobsmin,sitevectorobsmax], **kwargs)

    






