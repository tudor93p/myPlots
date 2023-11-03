import numpy as np
import Utils, Plot, Algebra

import plothelpers
import sliders 
from plothelpers import (
        get_one_or_many, 
        plot_levellines2, 
        deduce_axislimits,
        set_xylabels2,
        )


def nr_axes(**kwargs):

    return 1



common_sliders = [sliders.linewidths]






#===========================================================================#
#
#   plot
#
#---------------------------------------------------------------------------#
#def plot(Ax, get_plotdata, **kwargs):
#
#    data = get_plotdata(kwargs)
#
#    data.update(kwargs)
#
#    return plot0(Ax, **data) 
#



#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#

def plot(Ax, linewidth=1, fontsize=12, zorder0=0, dotsize=35, 
        xlim=None, ylim=None, aspect_ratio=None,
        linestyles=plothelpers.linestyles,
        colors=plothelpers.colors,
        lw2=0.5,lw1=1.5,
        alpha=0.65,
        kwargs_levellines={},
        kwargs_legend={},
        **data):

    ax0 = Ax[0]

    d = get_one_or_many(data)


    xlim,ylim = deduce_axislimits([d("x"),d("y")], [xlim,ylim])

#    nr_curves = max([len(L) for L in [d("label"),d("flabel")] if L is not None ])
    nr_curves = max([len(L) for L in [d("function"),d("y")] if L is not None ])



    LWS = np.linspace(lw1,lw2,nr_curves)*linewidth
   
    LSS = [linestyles[i%len(linestyles)] for i in range(nr_curves)] 


    ils = 0

    #alpha = 0.65    # transparency of x0 vs y


    if d("function") is not None:

        for (z,(f,l,c,lw)) in enumerate(zip(d("function"),d("flabel"),colors[1:],LWS)):
    
            with np.errstate(divide='ignore',invalid='ignore'):

                x,y = Utils.Adaptive_Sampling(f, xlim, min_points=100)
    
                if np.any(np.abs(y) > 1e-9):
   
                    ax0.plot(x, y[0], c=c, linewidth=lw, zorder=zorder0+2+z*2, alpha=alpha, label=l, linestyle=LSS[ils])#**LKS[ils])

                    ils+=1



    if d("y") is not None and d("x") is not None:

        for (z,(x,y,l,c,ls,lw)) in enumerate(zip(d("x"),d("y"),d("label"),colors[ils:], LSS, LWS)):
 
            xy = np.vstack((np.reshape(x,-1),np.reshape(y,-1)))

            if xy.shape[1]>1 and np.any(np.linalg.norm(np.diff(xy,axis=1),axis=0)>1e-9):

    
                ax0.plot(*xy, c=c, linewidth=lw, zorder=3*ils+zorder0+2+z*2, alpha=alpha, label=l, linestyle=ls) 


            else:

                ax0.scatter(*xy[:,0], c=c, s=dotsize, zorder=3*ils+zorder0+2+z*2, alpha=alpha, label=l,marker="X")




    if aspect_ratio is not None: ax0.set_aspect(aspect_ratio)



    set_xylabels2(ax0, data, fontsize=fontsize)
   

    nr_items_legend = len(ax0.get_legend_handles_labels()[0])

    if nr_items_legend>0:

        nrow = 4
       
        kl = {  "fontsize": fontsize,
                "ncol": (nr_items_legend-1)//nrow + 1,
                "columnspacing" : 1,
                }

        kl.update(kwargs_legend)

        ax0.legend(**kl)
       

    ax0.tick_params(labelsize=fontsize)
    
    if "zorder" not in kwargs_levellines:
        kwargs_levellines["zorder"] = zorder0+5 

    plot_levellines2(ax0, data, 
                        xlim=xlim, ylim=ylim, **kwargs_levellines)


    Plot.set_xyticks(ax0, **data)



