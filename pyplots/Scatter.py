from plothelpers import *
from sliders import *
import Algebra

def nr_axes(**kwargs):

    return 1


common_sliders = [dotsizes, colormap]



#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#


def restrict(A,mM):
    
    if mM is not None: 
       
        x = [l is not None for l in mM]

        if len(x)==2 and all(x):
           
            m,M = mM 

            return np.logical_and(A>m,A<M)

    return np.ones(A.shape,bool)


def mask(x,xlim,y,ylim,z=None):

    M = np.logical_and(restrict(x,xlim),restrict(y,ylim))

    if (M.any() and not M.all()): 

        return (x[M], y[M], z if z is None else z[M])

    else:

        return (x, y, z)







#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#

def plot(Ax, 
        dotsize=10, dotsize_var=0.3,
        fontsize=12, cmap="cool", zorder0=0, 
        xlim=None,ylim=None,zlim=None,
        zlabel="",
        show_colorbar=True,
        kwargs_levellines={},
        kwargs_colorbar={},
        **kwargs): 



    ax0 = Ax[0]

    alpha0 = 1#0.6

    d = get_one_or_many(kwargs)

    Y = d("y") # Must be there

    assert Y is not None 

    X = Utils.Assign_Value(d("x"), [np.arange(len(y)) for y in Y])

    Z = Utils.Assign_Value(d("z"), np.repeat(None, len(Y)))

    L = Utils.Assign_Value(d("label"), np.repeat(None, len(Y)))


    xlim,ylim,zlim = deduce_axislimits([X,Y,Z], [xlim,ylim,zlim])

    nr_col = 0


    for i,(x_,y_,z_,l) in enumerate(zip(X, Y, Z, L)):
       
        x,y,z = mask(x_,xlim,y_,ylim,z_)


        if z is None:
  

            ax0.scatter(x, y, s=dotsize, c=colors[nr_col], label=l, zorder=zorder0+2, marker=MARKERS[nr_col],alpha=alpha0)
   
            nr_col += 1

        else:
     
            S = (1+(2*np.random.rand(len(x))-1)*dotsize_var)*dotsize
          
            

            P = ax0.scatter(x, y, s=S, c=z, cmap=cmap, zorder=zorder0+2, vmax=zlim[1], vmin=zlim[0], label=l, marker=MARKERS[nr_col], alpha=alpha0)
       
            if i==0 and show_colorbar:

                Plot.good_colorbar(P, zlim, ax0, zlabel, fontsize=fontsize,
                        **kwargs_colorbar)
                pass            
    
    
    if len(Y) > 1 and not all([l is None for l in L]):

        ax0.legend(fontsize=fontsize)

    set_xylabels2(ax0, kwargs, fontsize=fontsize)
    
    if "zorder" not in kwargs_levellines:
        kwargs_levellines["zorder"] = zorder0+5 


    plot_levellines2(ax0, kwargs, 
            xlim=xlim,ylim=ylim,
            **kwargs_levellines,
            )


    Plot.set_xyticks(ax0, **kwargs)
    















