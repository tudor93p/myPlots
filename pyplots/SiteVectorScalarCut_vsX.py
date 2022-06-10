from sliders import * 

from SiteVectorScalarCut import common_sliders as common_sliders0 

from Z_vsX_vsY import plot as plot0, common_sliders as common_sliders1

from Z_vsX_vsY import nr_axes 




add_sliders, read_sliders = addread_sliders(*common_sliders0,
                                            *common_sliders1,
                                            )

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

    






