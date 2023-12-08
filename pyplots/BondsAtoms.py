import numpy as np

import Utils  

import sliders,plothelpers#from plothelpers import * 

#from sliders import *
from ColoredAtoms import plot as plot_atoms
from ColoredAtoms import nr_axes 
from ColoredAtoms import common_sliders as common_sliders0 


common_sliders = common_sliders0 + [sliders.linewidths,sliders.bondcolors]




#common_sliders = [atomsizes, colormap]




#===========================================================================#
#
#   plot
#
#---------------------------------------------------------------------------#


def plot(Ax, 
#        cmap="PuBuGn", atomsize=100, 
#        fontsize=12, 
#        zlabel=None, zlabels=None, show_colorbar=True, 
#        kwargs_colorbar={},
        bonds=None,
        bondwidth=None,
        bondcolor=None,
        linewidth=2,
        atom_limit=1000,
        zorder=0,
        **kwargs):



    if (bonds is None) or (len(bonds)==0) or (bondwidth==0): 
        return plot_atoms(Ax, **kwargs, zorder=zorder)


    d = plothelpers.get_one_or_many(kwargs) 

    XY = d("xy")

    nr_atoms = [xy.shape[1] for xy in XY] 

    if (atom_limit is not None) and any([n>atom_limit for n in nr_atoms]):

        return plot_atoms(Ax, **kwargs, zorder=zorder)


    plot_atoms(Ax, **kwargs, zorder=zorder+len(XY))




  # -------------------- plot bonds under atoms --------------------------- #
    
    ax0 = Ax[0]      


    ax0.plot(
            *np.swapaxes(bonds,0,2),
            color=Utils.Assign_Value(bondcolor,plothelpers.get_color(0)),
            linewidth=Utils.Assign_Value(bondwidth, linewidth),
            linestyle="-",
            zorder=zorder,
            )


#    ax0.plot(x[0],y[0],c,x[1],y[1],c,x[2],y[2],c)


#  

#ax.plot(t, t, 'r--', t, t**2, 'bs', t, t**3, 'g^')#
