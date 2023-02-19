import numpy as np
import Plot, Algebra, Utils
#from scipy.spatial import ConvexHull
import warnings
from plothelpers import *
from sliders import *
from scipy.interpolate import Rbf
import matplotlib.cm
#import Geometry
#import time  
from contrasting_cmaps import contrasting_cmap 



def nr_axes(**kwargs):

    return 1


common_sliders = [arrow_parameters, colormap, atomsizes, smoothen]






#===========================================================================#
#
#   plot
#
#---------------------------------------------------------------------------#

def plot(Ax, get_plotdata, 
        atomsize=100, 
        arrow_width=0.1,#0.001,
        arrow_scale=1.0,
        arrow_headwidth=0.41,#003,
        arrow_headlength=0.2,#005,
        arrow_minlength=0,#1e-3,
        arrow_maxlength=1,#1e-3,
        arrow_uniformsize=0.0,
        cmap="YlGnBu",
        vectormin=0,
        vectormax=None,
#        reverse_cmap=False,
        fontsize=12, 
        smooth=0,
        colorbar=True,
        **kwargs):



    ax0 = Ax[0]

    data = get_plotdata(kwargs)


    

    ax0.scatter(*data["nodes"].T[:2], c='k', s=atomsize, zorder=20)


    if "dRs" not in data:

        return 

    def control_size(S):

        if arrow_uniformsize==0:
            return S 

        return Utils.Rescale(Utils.Rescale(S)**(1-arrow_uniformsize),Algebra.minmax(S))


    XY = np.array(data.get("Rs",data["nodes"]))[:,0:2]

    UV = np.array(data["dRs"])[:,0:2]

    sizes = np.linalg.norm(UV, axis=1) #    scalar field  -> background
 

### 
    csizes = control_size(sizes)

    UV *= np.reshape(csizes/np.maximum(sizes,1e-8),(-1,1))  

    sizes = csizes  # or comment out 
### 



    [xm,ym],[xM,yM] = Algebra.minmax(data["nodes"][:,0:2],axis=0)

    if abs(yM-ym)<1e-9 or abs(xM-xm)<1e-9:

        if "Rs" in data:
            [xm,ym],[xM,yM] = Algebra.minmax(XY,axis=0)

        elif abs(yM-ym)<1e-9:
            
            ym,yM = xm,xM 
            
        elif abs(xM-xm)<1e-9:

            xm,xM = ym,yM 


    
    
    r = (xM-xm)/(yM-ym) 


    
    nx,ny = np.ceil(100*np.max([[1,1],[r,1/r]],axis=0)).astype(int)
    

    x, y = np.linspace(xm,xM,nx + (nx==ny)), np.linspace(ym,yM,ny)


    inds = np.where(np.logical_and(sizes >= arrow_minlength*np.max(sizes), sizes <= 1e-10 + arrow_maxlength*np.max(sizes)))[0]

####
#    if not any(inds): 
 #       return 

#    sizes = sizes[inds] 

#    UV = UV[inds]*arrow_scale

#    XY = XY[inds] 

###

    with warnings.catch_warnings():

        warnings.simplefilter("ignore")

        x_smooth,y_smooth = Utils.mgrid_from_1D(x,y,extend=True)

        arrowsize = Rbf(*XY.T, sizes, function='linear', smooth=50*smooth)(x_smooth,y_smooth)


    vmin = vectormin 

    vmax = max(vmin,Utils.Assign_Value(vectormax, np.max(sizes)))


    P = ax0.pcolormesh(x_smooth-(x[1]-x[0])/2, y_smooth-(y[1]-y[0])/2,
                arrowsize, #alpha = 0.6, 
                cmap=cmap, 
                edgecolors='face', #linewidth=0.001,#001,
                zorder=5,
                vmin=vmin, vmax=vmax)



    if colorbar: 

        label = "Arrow length"
        
        if "label" in data:
        
            label += "\n"+ data["label"]  

        Plot.good_colorbar(P, [vmin, vmax], ax0, label, fontsize=fontsize)



###
    if not any(inds):
        return

    UV = UV[inds]*arrow_scale

    XY = XY[inds] 
    sizes = sizes[inds]

### 


#    get_col = matplotlib.cm.get_cmap(cmap) 

    get_col2 = contrasting_cmap(cmap) 


    for (xy,dxy,s) in zip(XY-UV/2,UV, Utils.Rescale(sizes,[0,1],[vmin,vmax])): 

        ax0.arrow(*xy, *dxy, 
                        length_includes_head=True,
                        width=arrow_width,
                        head_width=arrow_headwidth,
                        head_length=arrow_headlength,
                        zorder=15,
                        color=get_col2(s),
                        )



    ax0.set_xlim(Plot.extend_limits([xm,xM],0.03))
    ax0.set_ylim(Plot.extend_limits([ym,yM],0.03))


    xlabel = data.get("xlabel","$x$") 

#    ax0.set_xlabel(data.get("xlabel","$x$"), fontsize=fontsize)

    ylabel = data.get("ylabel","$y$")

#    ylabel_kwargs = {"fontsize":fontsize}

#    if sum([c!="$" for c in ylabel])<=1:

#        ylabel_kwargs["rotation"]=0

#    ax0.set_ylabel(ylabel, **ylabel_kwargs)

    set_xylabels(ax0, [xlabel,ylabel], fontsize=fontsize)

    ax0.set_aspect(1)






