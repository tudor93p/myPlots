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

def nr_axes(**kwargs):

    return 1


common_sliders = [arrow_parameters, colormap, atomsizes]

add_sliders, read_sliders = addread_sliders(*common_sliders)



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
        fontsize=12, 
        **kwargs):



    ax0 = Ax[0]

    data = get_plotdata(kwargs)


    

#    if "nodes" in data:

    ax0.scatter(*data["nodes"].T[:2], c='k', s=atomsize, zorder=20)


    if "dRs" not in data:

        return 

    def control_size(S):
#        return S + arrow_uniformsize * (np.mean(S) - S)

        return Utils.Rescale(Utils.Rescale(S)**(1-arrow_uniformsize),Algebra.minmax(S))


    XY = np.array(data.get("Rs",data["nodes"]))[:,0:2]

    UV = np.array(data["dRs"])[:,0:2]

    sizes = np.linalg.norm(UV, axis=1) #    scalar field 


    [xm,ym],[xM,yM] = Algebra.minmax(data["nodes"],axis=0)

    if abs(yM-ym)<1e-9 or abs(xM-xm)<1e-9:

        if "Rs" in data:
            [xm,ym],[xM,yM] = Algebra.minmax(data["Rs"],axis=0)

        elif abs(yM-ym)<1e-9:
            
            ym,yM = xm,xM 
            
        elif abs(xM-xm)<1e-9:

            xm,xM = ym,yM 



    
    
    r = (xM-xm)/(yM-ym) 


    
    nx,ny = np.ceil(100*np.max([[1,1],[r,1/r]],axis=0)).astype(int)
    

    x, y = np.linspace(xm,xM,nx + (nx==ny)), np.linspace(ym,yM,ny)


    inds = np.where(np.logical_and(sizes >= arrow_minlength*np.max(sizes), sizes <= arrow_maxlength*np.max(sizes)))[0]


    with warnings.catch_warnings():

        warnings.simplefilter("ignore")


#        for i in set(range(len(Z))).difference(inds):
#            Z[i]=0

        x_smooth,y_smooth = Utils.mgrid_from_1D(x,y,extend=True)

        arrowsize = Rbf(*XY.T, sizes, function='linear', smooth=0)(x_smooth,y_smooth)


#        bondlengths = np.unique(la.norm(bonds,axis=1))
            

#        nr_bonds = np.count_nonzero(Algebra.OuterDist(Algebra.FlatOuterDist(Atoms,Atoms),bondlengths)<self.tol,axis=1).reshape(len(Atoms),len(Atoms)).sum(axis=0)

#    SurfaceAtoms = Atoms[nr_bonds < np.max(nr_bonds),:]

#        hull = alphashape.alphashape(points).exterior.coords.xy

       # hull = XY[ConvexHull(XY).vertices]


#        for (j,(xcol,ycol)) in enumerate(zip(x_smooth.T,y_smooth.T)):

#            for (i,P) in enumerate(zip(xcol,ycol)):

#                if not Geometry.PointInPolygon_wn(P, hull):

#                    arrowsize[i,j] = 0

#        arrowsize = interp2d(*XY.T, Z, kind='linear', fill_value=0)(x,y).T



#    vmin,vmax = [0,np.max(sizes)]

    vmin = vectormin
    vmax = Utils.Assign_Value(vectormax, np.max(sizes))

    P = ax0.pcolormesh(x_smooth-(x[1]-x[0])/2, y_smooth-(y[1]-y[0])/2,
                arrowsize, #alpha = 0.6, 
                cmap=cmap, 
                edgecolors='face', #linewidth=0.001,#001,
                zorder=5,
                vmin=vmin, vmax=vmax)

#    XY += np.array([x[1]-x[0],y[1]-y[0]])/2

    label = "Arrow length"
    
    if "label" in data:
    
        label = label + "\n"+ data["label"] 


    Plot.good_colorbar(P, [vmin, vmax], ax0, label,
            fontsize=fontsize)






#    u = interp2d(*XY.T, UV[:,0], fill_value=0)

#    v = interp2d(*XY.T, UV[:,1], fill_value=0)



#    ax0.streamplot(x, y, u(x,y), v(x,y),
#            linewidth=arrowsize*(arrowsize>arrow_minlength*np.max(arrowsize)),
#            density=arrow_scale,
#            arrowsize=arrow_scale,
#            )


#    ax0.quiver(x, y, u(x,y), v(x,y),
#            angles='xy',
#            color="k",
#            zorder=10
#            )
#



    sizes = sizes[inds]


    # for loop is slow!!

#    start=time.time()


    for (R,dR,c) in zip(
        XY[inds],
        UV[inds]*np.reshape(control_size(sizes)/sizes,(-1,1)),
        matplotlib.cm.get_cmap(cmap)(Utils.Rescale(sizes,[0,1])),
        ):

        dxy = arrow_scale * dR

        xy = R - dxy/2


        cc = tuple(np.append(1-np.array(c[:3]),c[3]))

#        cc = tuple(1-np.array(c))

        a = ax0.arrow(*xy, *dxy, 
                        length_includes_head=True,
                        width=arrow_width,
                        head_width=arrow_headwidth,
                        head_length=arrow_headlength,
                        zorder=15,
                        color=cc,
                        label=label,#data["label"],
                        )


#    ax0.legend(handles=[a],fontsize=fontsize)


#Algebra.minmax(


#    print(time.time()-start)
#    [xm,ym],[xM,yM] = Algebra.minmax(data["Rs"],axis=0)


    ax0.set_xlim(Plot.extend_limits([xm,xM],0.03))
    ax0.set_ylim(Plot.extend_limits([ym,yM],0.03))

    ax0.set_xlabel("$x$", fontsize=fontsize)
    ax0.set_ylabel("$y$", rotation=0, fontsize=fontsize)
    
    
    ax0.set_aspect(1)




