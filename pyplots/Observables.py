import numpy as np
import Plot,Algebra,Utils
from plothelpers import *
from sliders import *



def nr_axes(**kwargs):

    return 1


common_sliders = [observables, obs_group, obs_vminmax, obs_index]


local_sliders = common_sliders + [ linewidths, energy_zoom ]




#===========================================================================#
#
#   plot
#
#---------------------------------------------------------------------------#



def plot(Ax, obsmin=None, obsmax=None, Energy=None, enlim=None, linewidth=1, fontsize=12, 
        ylabel="",xlabel="",xlabel0="", y=None,
        weights=None,
        **kwargs):

    d = get_one_or_many(kwargs)


    ax0 = Ax[0]
    
    
    ax0.set_ylabel(ylabel,fontsize=fontsize)
    
    ic = 0          # color index 

    zorder = 0      # zorder of curves; increases after every plott
   

    restrict = np.logical_and(y>=min(enlim), y<=max(enlim))

    # ------------ check if there's some x_ to plot ---------------- #

    show_x = (xlabel is not None) and (xlabel != xlabel0)

    xm, xM = 0, 0

    if show_x:
                                # don't show if there's no curve
        show_x = False
        
        X = d("x_")

        if X is not None:

            for x_ in X: 
        
                if x_ is not None:

                    show_x = True

                    xm, xM = Algebra.minmax(np.append(np.array(x_)[np.array(restrict)],[xm,xM]))

    plusminus = xm*xM < 0





    # ------------ plot x0 ---------------- #
    

    alpha0 = 0.35    # transparency of x0 vs y_

    x0max = 0       # will store the maximum of x0




    for (x0,label0) in zip(d("x0"), d("label0")):


        if x0 is not None:

            x_,y_ = Plot.get_plotxy(axis=1)(y, x0, fill=0)
    
            ax0.fill(x_, y_, c=colors[ic], lw=0.5, zorder=zorder+1, alpha=alpha0, ec=colors[ic], label=label0)
   
            if plusminus:
                ax0.fill(-x_, y_, c=colors[ic], lw=0.5, zorder=zorder, alpha=alpha0, ec=colors[ic])

            ic +=1

            zorder += 2

            x0max = max(x0max,max(x0[restrict]))


    if x0max==0:    # nothing has been plotted
        x0max=1
    
    else:           # x0 has been plotted

        ax0.set_xlabel(xlabel0,fontsize=fontsize)

    if plusminus:
        ax0.plot([0,0], enlim, c='gray', lw=0.5, zorder=zorder)

        zorder += 2




    # ------------ Energy level  ---------------- #

    if Energy is not None and weights is not None:

        xmax = x0max


        xlim = ax0.get_xlim()

        if not show_x and obsmax is not None and xlim[0] < obsmax:

            xmax = obsmax

        x_,y_ = Plot.get_plotxy(axis=1)(
                y,
                np.reshape(weights,-1)/np.max(weights)*xmax,
                fill=0)

        ax0.fill(x_,y_, c=colors[ic], lw=0.5, zorder=1, alpha=alpha0, ec='k', label="weights")

        if plusminus:
            ax0.fill(-x_,y_, c=colors[ic], lw=0.5, zorder=1, alpha=alpha0, ec='k')

        ic += 1








    # ------------ plot x_ ---------------- #


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

        for (x_,l,lw) in zip(d("x_"), d("label"), LWS):
            
            if x_ is not None:
                
                ax1.plot(x_, y, color=colors[ic], linewidth=lw, 
                        label=l, zorder=zorder, linestyle=LSS[ic-ils0])
   
                    
                ic+=1

                zorder += 2

    
        ax1.set_xlabel(xlabel,fontsize=fontsize)
        
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
        
        x_ = ax.get_xlim()[1]

        if x_>obsmin:

            ax.set_xlim(obsmin,x_)
    
    if obsmax is not None:

        x_ = ax.get_xlim()[0]

        if x_ < obsmax:

            ax.set_xlim(x_,obsmax)

    
    
    # ---------------------------- #
    
    return ax
   


