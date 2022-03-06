from plothelpers import *
from sliders import *
import Algebra

def nr_axes(**kwargs):

    return 1


common_sliders = [dotsizes, colormap, smoothen]

add_sliders, read_sliders = addread_sliders(*common_sliders)


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








def plot(Ax, get_plotdata, dotsize=10, fontsize=12, 
            cmap="PuBu", zorder0=0, **kwargs): 

    ax0 = Ax[0]

    data = get_plotdata(kwargs)

    d = get_one_or_many(data)

    get_val = Utils.prioritized_get(kwargs,data)


    Y = d("y") # Must be there

    X = Utils.Assign_Value(d("x"), [np.arange(len(y)) for y in Y])

    Z = Utils.Assign_Value(d("z"), np.repeat(None, len(Y)))

    L = Utils.Assign_Value(d("label"), np.repeat(None, len(Y)))


#    print()
#    for c in ["x","y","z"]:
#
#        s= c+"lim"
#
#        print(s,"=",get_val(s))
#
#    print()
    
    xlim,ylim,zlim = deduce_axislimits([X,Y,Z], 
                                  [get_val(c+"lim") for c in ["x","y","z"]])

#    print()
#    for c,l in zip(["x","y","z"],xyzlims):
#
#        s= c+"lim"
#
#        print(s,"=",get_val(s))
#        print("new lim =",l)
#
#
#    print()

    nr_col = 0





    for i,(x_,y_,z_,l) in enumerate(zip(X, Y, Z, L)):
       
        x,y,z = mask(x_,xlim,y_,ylim,z_)


        if z is None:
    
            ax0.scatter(x, y, s=dotsize, c=colors[nr_col], label=l, zorder=zorder0+2)
   
            nr_col += 1

        else:
      
            S = (1+(2*np.random.rand(len(x))-1)*0.3)*dotsize
          
            

            P = ax0.scatter(x, y, s=S, c=z, cmap=cmap, zorder=zorder0+2, vmax=zlim[1], vmin=zlim[0], label=l)#, alpha=0.8)
       
            if i==0 and get_val("show_colorbar", True):

                Plot.good_colorbar(P, zlim, ax0, data.get("zlabel",""), fontsize=fontsize)
            
    
    
    if len(Y) > 1 and not all([l is None for l in L]):

        ax0.legend(fontsize=fontsize)



    ax0.set_xlim(xlim)

    ax0.set_ylim(ylim)

    
    plot_levellines(ax0, get_val, zorder=zorder0+5, color="k", lw=1, alpha=0.6)


    set_xylabels(ax0, get_val, fontsize=fontsize)



















