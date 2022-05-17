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


    P = ax0.pcolormesh(*Utils.mgrid_from_1D(data["x"],data["y"]), data["z"],
                        cmap=cmap, edgecolors='face',
      		        zorder=2, vmax=zlim[1], vmin=zlim[0])
  

    if get_val("show_colorbar", True):

        Plot.good_colorbar(P, zlim, ax0, data.get("zlabel",""), fontsize=fontsize)
   

    if ("x_plot" in data) and ("y_plot" in data):

        ax0.plot(data["x_plot"], data["y_plot"], zorder=10, color="red", lw=2, ls="--", alpha=0.7) 




    for k,f in [("xlim",ax0.set_xlim),("ylim",ax0.set_ylim)]:

        lim = get_val(k)

        if lim is not None: f(lim)



  
    def get_line(cline):

        line = get_val(cline)

        if line is None:

            return None 

        vals = np.array(data[cline[0]])

        i = np.argmin(np.abs(vals - line))

        if i+1 == len(vals):

            return vals[i] + np.mean(np.diff(vals))/2

        else:

            return np.mean(vals[i:i+2])

    plot_levellines(ax0, get_line, zorder=5, color="k", lw=1, alpha=0.6)
    
    set_xylabels(ax0, get_val, fontsize=fontsize)


    inds = [None,None]

    for (i,c) in enumerate("xy"):

        L = get_val(c+"line")

        if L is not None:

            inds[i] = np.argmin(np.abs(data[c]-L))
   


    if all([i is not None for i in inds]):

        z0 = np.round(data["z"][inds[0],inds[1]],2)

        ax0.set_xlabel(ax0.get_xlabel() + " [$z="+str(z0)+"$]")

    














