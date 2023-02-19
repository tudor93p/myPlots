from plothelpers import *
import itertools
import numpy as np
from sliders import *

def nr_axes(**kwargs):

    return 1


local_sliders = [atomsizes, linewidths, pick_systems]


#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#


def plot(Ax, get_plotdata, linewidth=1, atomsize=10, fontsize=12, **kwargs):


    ax0 = Ax[0]

   
    data = get_one_or_many(get_plotdata(kwargs))

    c = 1

    for i,latt in enumerate(data("lattice")):

        latt.Plot_Lattice(  ax_fname=ax0,
                            ns_or_UCs=["ns",3],
                            labels=True,
                            bondcols=colors[c:c+1],
                            sublattcols=colors[c+1:],
                            zorder=3*i,
                            fontsize=10,
                            atomsize=atomsize,
                            bondwidth=linewidth)
                            
        c += len(latt.Sublattices) + 1


#  xlim5,ylim5 = ax0.get_xlim(),ax0.get_ylim()
#
#  ax1 = ax0.twinx()
#
#  oneplot(ax1,SC_param)
#
#  ax0.set_xlim(xlim5)
#
#  ax1.set_xlim(xlim5)
#  ax0.set_ylim(ylim5)
#
    ax0.set_xlabel("$x$")
    ax0.set_ylabel("$y$",rotation=0)
#  ax1.set_ylabel("SC param")
#
#
#
