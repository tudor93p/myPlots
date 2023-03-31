import numpy as np
import Plot,Algebra,Utils
from plothelpers import *
from sliders import *
import contrasting_cmaps 
import warnings 

import matplotlib.pyplot as plt #colors 
from matplotlib.colors import is_color_like 

def nr_axes(**kwargs):

    return 1

common_sliders = [colormap, contour]



#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#



def warning_on_one_line(message, category, filename, lineno, file=None, line=None):
        return '%s:%s: %s:%s\n' % (filename, lineno, category.__name__, message)

warnings.formatwarning = warning_on_one_line

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

def get_cc(contour_color, cmap="viridis"):

    if contour_color is None:
        return {"colors":None}


    if isinstance(contour_color,list): 

        if all([is_color_like(c) for c in contour_color]):
            return {"colors":contour_color} 


    if not isinstance(contour_color,str):
        warnings.warn(f"The type of the color/cmap '{contour_color}' not understood.")

        return {"colors":None}


    if contour_color == "contrasted":
        if contrasting_cmaps.isprecomputed(cmap):
            return {"cmap":contrasting_cmaps.listed_cmap(cmap)}

    if contour_color == "reversed":

        return {"cmap":Plot.reverse_cmap(cmap)}

    if contour_color in plt.colormaps():
        return {"cmap": contour_color}


    if is_color_like(contour_color):

        return {"colors":contour_color}

    warnings.warn(f"The color/cmap '{contour_color}' does not exist.")

    return {"colors":None}



#matplotlib.colors.cnames 

def get_cl(cnlev, zlim):

    if cnlev is None:
        return None 

    if isinstance(cnlev,list) or isinstance(cnlev,np.ndarray):
        return np.sort(cnlev)

    if isinstance(cnlev,int):
        return cnlev 

    
    if isinstance(cnlev,float):
        
        if cnlev>0:
            return np.arange(*zlim,cnlev)
    
        else:
            return np.arange(*reversed(zlim),cnlev)[::-1] 
    
    raise Exception(f"'cnlev={cnlev}' not implemented")

        

#===========================================================================#
#
#   Plot - requires data dictionary with:
#       "x", "y"  1D, 
#       "z" 2D
#       "xlabel", "ylabel", "zlabel", str 
#
#---------------------------------------------------------------------------#



def plot(Ax, fontsize=12, 
        xlim=None, ylim=None,zlim=None,
        cmap="viridis",
        contour_levels=None,
        contour_color=None,
        show_colorbar=True,
        x=None, y=None, z=None,
        aspect_ratio=None,
        zlabel="",
        **data): 

    assert x is not None 
    assert y is not None 
    assert z is not None 


    ax0 = Ax[0]

    zlim = deduce_axislimits([z],[zlim])


    X = shift_by_Dx(x,-1/2)
    Y = shift_by_Dx(y,-1/2)

    P = ax0.pcolormesh(*Utils.mgrid_from_1D(X,Y), z,
                        cmap=cmap, edgecolors='face',
      		        zorder=2, vmax=zlim[1], vmin=zlim[0])
 
    cbarticks = None 


    cnlev = get_cl(contour_levels, zlim)

    if cnlev is not None:


#        z[z<zlim[0]]=zlim[0]
#        z[z>zlim[1]]=zlim[1]


        p = ax0.contour(*Utils.mgrid_from_1D(x,y,extend=False),
                z, cnlev, 
                zorder=5,
                **get_cc(contour_color, cmap)
                )

        cbarticks = p.levels  



    if show_colorbar:

        Plot.good_colorbar(P, zlim, ax0, zlabel, fontsize=fontsize, ticks=cbarticks)
   

    if ("x_plot" in data) and ("y_plot" in data):

        ax0.plot(data["x_plot"], data["y_plot"], zorder=10, color="red", lw=2, ls="--", alpha=0.7) 




    for (v,lim,f) in [(x,xlim,ax0.set_xlim),(y,ylim,ax0.set_ylim)]:

        if lim is not None:

            f([shift_by_dx(v,*ls) for ls in zip(lim,[-1/2,1/2])])


  

    plot_levellines2(ax0, data, zorder=5, color="k", lw=1, alpha=0.6,
            xlim=xlim,ylim=ylim)

    set_xylabels2(ax0, data, fontsize=fontsize)


    i,j = [closest_data_i(v,data.get(c+"line",None),1)[0] for (v,c) in [(x,"x"),(y,"y")]]


    if (i is not None) and (j is not None):

        z0 = np.round(z[i,j],2)

        ax0.set_xlabel(ax0.get_xlabel() + " [$z="+str(z0)+"$]")




    if aspect_ratio is not None:
        ax0.set_aspect(aspect_ratio)













