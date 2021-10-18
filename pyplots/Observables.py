import numpy as np
import Plot,Algebra,Utils
from plothelpers import *
from sliders import *



def nr_axes(**kwargs):

    return 1


common_sliders = [observables, obs_vminmax, obs_index]


add_sliders, read_sliders = addread_sliders(*common_sliders,
                                    linewidths,
                                    energy_zoom, 
                                    )




#===========================================================================#
#
#   plot
#
#---------------------------------------------------------------------------#



def plot(Ax, get_plotdata, obsmin=None, obsmax=None, Energy=None, enlim=None, linewidth=1, fontsize=12, **kwargs):

    data = get_plotdata({"Energy":Energy, **kwargs})
    
    d = get_one_or_many(data)


    ax0 = Ax[0]
    
    
    ax0.set_ylabel(data["ylabel"],fontsize=fontsize)
    
    ic = 0          # color index 

    zorder = 0      # zorder of curves; increases after every plott
   

    restrict = np.logical_and(data["y"]>=min(enlim), data["y"]<=max(enlim))

    # ------------ check if there's some x to plot ---------------- #

    show_x = ("xlabel" in data) and (data["xlabel"] != data["xlabel0"])

    xm, xM = 0, 0

    if show_x:
                                # don't show if there's no curve
        show_x = False
        
        X = d("x")

        if X is not None:

            for x in X: 
        
                if x is not None:

                    show_x = True

                    xm, xM = Algebra.minmax(np.append(np.array(x)[np.array(restrict)],[xm,xM]))

    plusminus = xm*xM < 0





    # ------------ plot x0 ---------------- #
    

    alpha0 = 0.35    # transparency of x0 vs y

    x0max = 0       # will store the maximum of x0




    for (x0,label0) in zip(d("x0"), d("label0")):


        if x0 is not None:

            x,y = Plot.get_plotxy(axis=1)(data["y"], x0, fill=0)
    
            ax0.fill(x, y, c=colors[ic], lw=0.5, zorder=zorder+1, alpha=alpha0, ec=colors[ic], label=label0)
   
            if plusminus:
                ax0.fill(-x, y, c=colors[ic], lw=0.5, zorder=zorder, alpha=alpha0, ec=colors[ic])

            ic +=1

            zorder += 2

            x0max = max(x0max,max(x0[restrict]))


    if x0max==0:    # nothing has been plotted
        x0max=1
    
    else:           # x0 has been plotted

        ax0.set_xlabel(data["xlabel0"],fontsize=fontsize)

    if plusminus:
        ax0.plot([0,0], enlim, c='gray', lw=0.5, zorder=zorder)

        zorder += 2




    # ------------ Energy level  ---------------- #

    if Energy is not None and "weights" in data:

        xmax = x0max


        xlim = ax0.get_xlim()

        if not show_x and obsmax is not None and xlim[0] < obsmax:

            xmax = obsmax

        x,y = Plot.get_plotxy(axis=1)(
                data["y"],
                np.reshape(data["weights"],-1)/np.max(data["weights"])*xmax,
                fill=0)

        ax0.fill(x,y, c=colors[ic], lw=0.5, zorder=1, alpha=alpha0, ec='k', label="weights")

        if plusminus:
            ax0.fill(-x,y, c=colors[ic], lw=0.5, zorder=1, alpha=alpha0, ec='k')

        ic += 1








    # ------------ plot x ---------------- #


    if not show_x:

        ax0.legend(fontsize=fontsize)

        ax = ax0

    else:

        ax1 = ax0.twiny()

        ax1.tick_params(labelsize=fontsize)

        ax = ax1

        if plusminus:
        
            ax1.plot([0,0], enlim, c='gray', lw=0.5, zorder=zorder-1)

        LWS = np.linspace(1.5,0.5, len(d("label")))*linewidth

        ils0 = ic 

        LSS = [linestyles[i%len(linestyles)] for i in range(len(d("label")))]

        for (x,l,lw) in zip(d("x"), d("label"), LWS):
            
            if x is not None:
                
                ax1.plot(x, data["y"], color=colors[ic], linewidth=lw, 
                        label=l, zorder=zorder, linestyle=LSS[ic-ils0])
   
                    
                ic+=1

                zorder += 2

    
        ax1.set_xlabel(data["xlabel"],fontsize=fontsize)
        
        ax1.set_ylim(enlim)
        
        ax1.legend(*Plot.collect_legends(ax0,ax1),fontsize=fontsize)#,  loc="upper right")
       






    # ------------ set some limits ---------------- #


    if plusminus:
        ax0.set_xlim(x0max*1.01*np.array([-1,1]))
        ax1.set_xlim(np.max(np.abs([xm,xM]))*1.01*np.array([-1,1]))

    else: 
        ax0.set_xlim(0,x0max*1.03)

        if show_x:
            ax1.set_xlim(0, xM*1.03)
            
    ax0.set_ylim(enlim)

    
    if obsmin is not None:
        
        x = ax.get_xlim()[1]

        if x>obsmin:

            ax.set_xlim(obsmin,x)
    
    if obsmax is not None:

        x = ax.get_xlim()[0]

        if x < obsmax:

            ax.set_xlim(x,obsmax)

    
    
    # ---------------------------- #
    
    return ax
   


