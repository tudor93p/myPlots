from sliders import * 

from SiteVectorScalarCut import common_sliders as common_sliders0 

from Z_vsX_vsY import plot as plot0, common_sliders as common_sliders1

from Z_vsX_vsY import nr_axes 




local_sliders = common_sliders0 + common_sliders1 

#===========================================================================#
#
#   plot
#
#---------------------------------------------------------------------------#

def plot(Ax, sitevectorobsmin=None, sitevectorobsmax=None, **kwargs):

    plot0(Ax, zlim=[sitevectorobsmin,sitevectorobsmax], **kwargs)

    






