import numpy as np
import Plot, Algebra 
import plothelpers
from plothelpers import *
from sliders import *

def nr_axes(**kwargs):
    return 1


common_sliders = [atomsizes, atomcolors] #, colormap]




#===========================================================================#
#
#   plot
#
#---------------------------------------------------------------------------#


def plot(Ax, cmap="PuBuGn", atomsize=100, fontsize=12, 
        zlabel=None, zlabels=None, show_colorbar=True, 
        kwargs_colorbar={},
        zorder=0,
        atomcolor=None,
        **kwargs):

    if len(kwargs_colorbar)>0:
        raise Exception("kwargs_colorbar not implemented")

    ax0 = Ax[0]


    d = get_one_or_many(kwargs)


    XY =  d("xy")
    Z = d("z")

    L = Utils.Assign_Value(d("label"), np.repeat(None, len(XY)))





    if Z is None:

        for i,(xy,lab) in enumerate(zip(XY,L)):

            ax0.scatter(*xy[:2], 
                    s=atomsize, 
                    c=Utils.Assign_Value(atomcolor,plothelpers.get_color(i)),
                    label=lab,
                    zorder=zorder,
                    )

        if sum(map(lambda l: l is not None, L))>1: 

            ax0.legend(fontsize=fontsize)  


        xylim = [Algebra.minmax([Algebra.minmax(R[i]) for R in XY]) for i in range(2)]

        wH = np.diff(xylim, axis=1).reshape(-1) 

        m,M = Algebra.minmax(wH)

        if M < 100*m:

            r = M/m

            pad = np.full(2, 0.1)  
    
            pad[np.argmin(wH)] = np.matmul([[2*r,0],[r,r-1]], [pad[0], 1]).min()
    
        
            for (lim, p, setlim) in zip(xylim, pad, [ax0.set_xlim,ax0.set_ylim]):
    
                setlim(Plot.extend_limits(lim,p/2)) 
    
            ax0.set_aspect(1)
    
        ax0.set_xlabel(r"$x\ [a]$",fontsize=fontsize)

#        ax0.set_ylabel("$y$",rotation=0,fontsize=fontsize)
        ax0.set_ylabel(r"$y\ [a]$",rotation=90,fontsize=fontsize)

        ax0.tick_params(labelsize=fontsize)


        return

#  if len(Z)>1:
#      raise 



#    kw = {"vminmax" : Algebra.minmax(data["z"])}

#    kw = {} 
#
#    if len(XY)==1 and zlabel is not None:
#
#        kw["cbarlabs"] = [zlabel]
#
#    elif len(XY)>1 and zlabels is not None: 
#
#        kw["cbarlabs"] = zlabels 
#
#    else:
#
#        ZL = d("zlabel")
#        
#        if ZL is not None:
#
#            kw["cbarlabs"] = ZL 
#            
#
#
#
#    Plot.LDOS([np.hstack((xy[:2].T,z.reshape(-1,1))) for (xy,z) in zip(XY,Z)],
#                ax_fname=ax0,
#                plotmethod="scatter",
#                axtitle="",
#                cmaps=[cmap for z in Z],
#                fontsize=fontsize,
#                dotsize=atomsize,
#                show_colorbar=show_colorbar,
#                **kw
#            )
#   
#
    
    





