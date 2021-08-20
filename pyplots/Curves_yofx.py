import numpy as np
import Utils, Plot, Algebra
from plothelpers import *
from sliders import *


def nr_axes(**kwargs):

    return 1



common_sliders = [linewidths,smoothen]


add_sliders,read_sliders = addread_sliders(*common_sliders)




#===========================================================================#
#
#   plot
#
#---------------------------------------------------------------------------#



def plot(Ax, get_plotdata, linewidth=1, fontsize=12, **kwargs):

            
    data = get_plotdata(kwargs)
    
    d = get_one_or_many(data)


    ax0 = Ax[0]
    
    get_val = Utils.prioritized_get(kwargs, data)

    xlim,ylim = deduce_axislimits([d("x"),d("y")],[get_val("xlim"),get_val("ylim")])


    nr_curves = len(d("label"))

    LWS = np.linspace(1.5,0.5,nr_curves)*linewidth
   
#    LKS = list(linekwargs(nr_curves))

    LSS = [linestyles[i%len(linestyles)] for i in range(nr_curves)]

    ils = 0

    alpha = 0.6    # transparency of x0 vs y

    if d("function") is not None:

        for (z,(f,l,c,lw)) in enumerate(zip(d("function"),d("label"),colors[1:],LWS)):
    
    
            with np.errstate(divide='ignore',invalid='ignore'):


                x,y = Utils.Adaptive_Sampling(f, xlim, min_points=100)
    
                if np.any(np.abs(y) > 1e-9):
    
                    ax0.plot(x, y[0], c=c, linewidth=lw, zorder=2+z*2, alpha=alpha, label=l, linestyle=LSS[ils])#**LKS[ils])

                    ils+=1



    elif d("y") is not None and d("x") is not None:

        for (z,(x,y,l,c,lw)) in enumerate(zip(d("x"),d("y"),d("label"),colors[1:], LWS)):
   

            if np.any(np.abs(y) > 1e-9):
    
                ax0.plot(np.reshape(x,-1), np.reshape(y,-1), c=c, linewidth=lw, zorder=2+z*2, alpha=alpha, label=l, linestyle=LSS[ils])#**lk)

                ils+=1


#            ax0.plot(np.reshape(x,-1), np.reshape(y,-1), c=c, linewidth=lw, zorder=2+z*2, alpha=alpha, label=l, linestyle=LSS[ils])#**lk)



















    ax0.set_xlim(xlim)
    ax0.set_ylim(ylim)

    set_xylabels(ax0, get_val, fontsize=fontsize)

    ax0.legend(fontsize=fontsize)
    
    ax0.tick_params(labelsize=fontsize)

    plot_levellines(ax0, get_val, zorder=5, color="k", lw=1, alpha=0.6) 






