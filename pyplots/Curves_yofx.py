import numpy as np
import Utils, Plot, Algebra
from plothelpers import *
from sliders import *


def nr_axes(**kwargs):

    return 1



common_sliders = [linewidths,smoothen,transforms]


add_sliders,read_sliders = addread_sliders(*common_sliders)




#===========================================================================#
#
#   plot
#
#---------------------------------------------------------------------------#



def plot(Ax, get_plotdata, linewidth=1, fontsize=12, zorder0=0, dotsize=35, **kwargs):

            
    data = get_plotdata(kwargs)
    
    d = get_one_or_many(data)


    ax0 = Ax[0]
    
    get_val = Utils.prioritized_get(kwargs, data)

    xlim,ylim = deduce_axislimits([d("x"),d("y")],[get_val("xlim"),get_val("ylim")])


    nr_curves = max([len(L) for L in [d("label"),d("flabel")] if L is not None ])



    LWS = np.linspace(1.5,0.5,nr_curves)*linewidth
   
    LSS = [linestyles[i%len(linestyles)] for i in range(nr_curves)] 


    ils = 0

    alpha = 0.65    # transparency of x0 vs y

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

#            if np.any(np.abs(y) > 1e-9):
    
                ax0.plot(*xy, c=c, linewidth=lw, zorder=3*ils+zorder0+2+z*2, alpha=alpha, label=l, linestyle=ls) 

            else:

                ax0.scatter(*xy[:,0], c=c, s=dotsize, zorder=3*ils+zorder0+2+z*2, alpha=alpha, label=l,marker="X")












    if "aspect_ratio" in data:

        ax0.set_aspect(data["aspect_ratio"])




    ax0.set_xlim(xlim)
    ax0.set_ylim(ylim)

    set_xylabels(ax0, get_val, fontsize=fontsize)

    nr_items_legend = len(ax0.get_legend_handles_labels()[0])

    if nr_items_legend>0:

        nrow = 4

        ncol = (nr_items_legend-1)//nrow + 1 

        ax0.legend(fontsize=fontsize, ncol=ncol, columnspacing=1)
       
    ax0.tick_params(labelsize=fontsize)

    plot_levellines(ax0, get_val, zorder=zorder0+5, color="k", lw=1, alpha=0.6) 





#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#



#def plot(Ax, get_plotdata, **kwargs):
#
#    return plot_direct(Ax[0], **get_plotdata(kwargs), **kwargs)


def plot_direct(ax0, linewidth=1, fontsize=12, zorder0=0, dotsize=35, 
        xlim=None, ylim=None, aspect_ratio=None,
        **data):


    d = get_one_or_many(data)


    xlim,ylim = deduce_axislimits([d("x"),d("y")], [xlim,ylim])

    nr_curves = max([len(L) for L in [d("label"),d("flabel")] if L is not None ])



    LWS = np.linspace(1.5,0.5,nr_curves)*linewidth
   
    LSS = [linestyles[i%len(linestyles)] for i in range(nr_curves)] 


    ils = 0

    alpha = 0.65    # transparency of x0 vs y


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



    set_xylabels(ax0, lambda v: data.get(v,None), fontsize=fontsize)
   

    nr_items_legend = len(ax0.get_legend_handles_labels()[0])

    if nr_items_legend>0:

        nrow = 4

        ncol = (nr_items_legend-1)//nrow + 1 

        ax0.legend(fontsize=fontsize, ncol=ncol, columnspacing=1)
       

    ax0.tick_params(labelsize=fontsize)

    plot_levellines(ax0, lambda v: data.get(v,None), zorder=zorder0+5,
                        xlim=xlim, ylim=ylim)





