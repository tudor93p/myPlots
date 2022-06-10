from sliders import *


from Curves_yofx import nr_axes, plot as plot0 

from Curves_yofx import common_sliders as common_sliders2 


from SiteVectorScalarCut_atE import common_sliders as common_sliders3  

from SiteVector import common_sliders as common_sliders0


common_sliders = common_sliders0 + common_sliders3 + [sitevectorobs_vminmax]


add_sliders, read_sliders = addread_sliders(*common_sliders,*common_sliders2)



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








