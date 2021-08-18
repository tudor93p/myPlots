import numpy as np
import Plot, Algebra, Utils
from plothelpers import *
from sliders import *
from Z_vsX_vsY import common_sliders as common_sliders0

def nr_axes(**kwargs):

    return 1



common_sliders = [local_observables, localobs_vminmax]



add_sliders, read_sliders = addread_sliders(
                                *common_sliders,
                                *common_sliders0,
                                choose_energy, 
                                #choose_k, #? 
                                atomsizes,
                                )



#===========================================================================#
#
#   plot
#
#---------------------------------------------------------------------------#


def plot(Ax, get_plotdata, localobs=None, cmap="PuBuGn", atomsize=100, 
        lobsmin=None, lobsmax=None, fontsize=12, **kwargs):




    ax0 = Ax[0]

    data = get_plotdata({"localobs":localobs, **kwargs})

    if localobs is None or not islocal(localobs) or "z" not in data:

        ax0.scatter(*data["xy"][:2], s=atomsize)

        return


    vmin,vmax = Algebra.minmax(data["z"])


    if lobsmin is not None:

        if lobsmin < vmax:

            vmin = lobsmin
    
    if lobsmax is not None:

        if lobsmax > vmin:

            vmax = lobsmax
    

    Plot.LDOS(  [np.hstack((data["xy"][:2].T,data["z"].reshape(-1,1)))],
                ax_fname=ax0,
                plotmethod="scatter",
                axtitle="",
                cmaps=[cmap],
                fontsize=fontsize,
                vminmax = [vmin,vmax],
                dotsize=atomsize,
                cbarlabs=[localobs],
            )
   

    ax0.set_xlabel("$x$",fontsize=fontsize)
    ax0.set_ylabel("$y$",rotation=0,fontsize=fontsize)
    
    





