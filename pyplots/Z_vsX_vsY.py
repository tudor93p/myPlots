import numpy as np
import Plot,Algebra,Utils
from plothelpers import *
from sliders import *

def nr_axes(**kwargs):

    return 1

common_sliders = [colormap]

add_sliders, read_sliders = addread_sliders(*common_sliders)



#===========================================================================#
#
# some helper functions 
#
#---------------------------------------------------------------------------#


def closest_data_i(X,x,n):

    if x is None:
        return [None for i in range(n)]

    return np.argpartition(np.abs(X-x),range(n))[:n]
    
#def closest_data(X,x,n):
#    return X[closest_data_i(X,x,n)]

#def get_step(X, i=None):
#    
#    if len(X)<=1:
#        raise Exception() 
#
#    if i is None: 
#        return np.mean(np.diff(X))
#
#    if i >= len(X) - 1:
#        return get_step(X, len(X)-2)
#
#
#    return X[i+1]-X[i] 
    
def shift_by_dx(X, x, f):

#    if x is None:
#        return None 

    return x + abs(np.diff(X[closest_data_i(X, x, 2)])[0])*f

def shift_by_Dx(X, f):

    Dx = np.diff(X) 

    return X + np.append(Dx,Dx[-1])*f


#===========================================================================#
#
#   Plot - requires data dictionary with:
#       "x", "y"  1D, 
#       "z" 2D
#       "xlabel", "ylabel", "zlabel", str 
#
#---------------------------------------------------------------------------#



def plot(Ax, get_plotdata, cmap="viridis", fontsize=12, **kwargs): 

    ax0 = Ax[0]

    data = get_plotdata(kwargs)

    get_val = Utils.prioritized_get(kwargs, data)

    zlim = deduce_axislimits([data["z"]],[get_val("zlim",[None,None])])


    X = shift_by_Dx(data["x"],-1/2)
    Y = shift_by_Dx(data["y"],-1/2)

    P = ax0.pcolormesh(*Utils.mgrid_from_1D(X,Y), data["z"],
                        cmap=cmap, edgecolors='face',
      		        zorder=2, vmax=zlim[1], vmin=zlim[0])
  

    if get_val("show_colorbar", True):

        Plot.good_colorbar(P, zlim, ax0, data.get("zlabel",""), fontsize=fontsize)
   

    if ("x_plot" in data) and ("y_plot" in data):

        ax0.plot(data["x_plot"], data["y_plot"], zorder=10, color="red", lw=2, ls="--", alpha=0.7) 




    for k,f in [("xlim",ax0.set_xlim),("ylim",ax0.set_ylim)]:

        lim = get_val(k)

        if lim is not None:

            f([shift_by_dx(data[k[0]],*ls) for ls in zip(lim,[-1/2,1/2])])


  

    plot_levellines(ax0, get_val, zorder=5, color="k", lw=1, alpha=0.6)
    set_xylabels(ax0, get_val, fontsize=fontsize)


    i,j = [closest_data_i(data[c],get_val(c+"line"),1)[0] for (i,c) in enumerate("xy")]


    if (i is not None) and (j is not None):

        z0 = np.round(data["z"][i,j],2)

        ax0.set_xlabel(ax0.get_xlabel() + " [$z="+str(z0)+"$]")




    if "aspect_ratio" in data:

        ax0.set_aspect(data["aspect_ratio"])













