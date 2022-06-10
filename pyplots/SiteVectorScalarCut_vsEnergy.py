from sliders import * 

from SiteVectorScalarCut import common_sliders as common_sliders0

from Z_vsX_vsEnergy import common_sliders as common_sliders1

from Z_vsX_vsEnergy import nr_axes  

from Z_vsX_vsEnergy import plot as plot0 



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

    






