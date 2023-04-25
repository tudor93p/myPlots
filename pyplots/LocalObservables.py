import numpy as np
import Plot, Algebra, Utils
from plothelpers import *
from sliders import *

def nr_axes(**kwargs):

    return 1



common_sliders = [local_observables, localobs_vminmax]

local_sliders = common_sliders + [colormap, choose_energy, atomsizes]



#===========================================================================#
#
#   plot
#
#---------------------------------------------------------------------------#


def plot(Ax, localobs=None, cmap="PuBuGn", atomsize=100, 
        lobsmin=None, lobsmax=None, fontsize=12, show_colorbar=True, 
        z=None,xy=None,
        kwargs_colorbar={},
        **kwargs):


    ax0 = Ax[0]


    if localobs is None or not islocal(localobs) or z is None:

        ax0.scatter(*xy[:2], s=atomsize)

        return


    vmin,vmax = Algebra.minmax(z)


    if lobsmin is not None:

        if lobsmin < vmax:

            vmin = lobsmin
    
    if lobsmax is not None:

        if lobsmax > vmin:

            vmax = lobsmax
    

    Plot.LDOS(  [np.hstack((xy[:2].T,z.reshape(-1,1)))],
                ax_fname=ax0,
                plotmethod="scatter",
                axtitle="",
                cmaps=[cmap],
                fontsize=fontsize,
                vminmax = [vmin,vmax],
                dotsize=atomsize,
                cbarlabs=[localobs],
                show_colorbar=show_colorbar,
                kwargs_colorbar=kwargs_colorbar,
            )
   

    
    





