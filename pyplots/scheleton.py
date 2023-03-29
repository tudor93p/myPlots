from importlib import import_module
import numpy as np
from plothelpers import *
import PlotPyQt
import time
import sliders
import matplotlib.pyplot as plt 

def get_axes(Axes, inds_axes_, subplot_nr):

    inds = (inds_axes_[subplot_nr], inds_axes_[subplot_nr+1]) 

    if np.ndim(Axes)==0: 

        assert inds[0]==inds[1]-1==0 
        
        return np.array([Axes])
        
    return Axes[np.unravel_index(np.arange(*inds), Axes.shape)]

def combine_data_and_P(f, P):

    data = f(P)

    data.update(P)

    return data  


def plot_one_timed(axes, libr, **P):
    
    (lib, f, title) = libr
   
    start0 = time.time()

#    out = lib.plot(axes, f, **P) 

    out = lib.plot(axes, **combine_data_and_P(f, P))


    print(title+": "+str(int(time.time()-start0))+"s\n") 

    return out 


def plot_one(axes, libr, fontsize=None, **P):

    plot_one_timed(axes, libr, fontsize=fontsize, **P)
    
    if len(axes)==1:

        axes[0].set_title(printable_string(libr[2]), fontsize=fontsize)

    Plot.set_fontsize(axes, fontsize)


def add_inset_axes(N, NrsAxes_all, inset, axes, inset_position, fontsize):

    n = min(N, NrsAxes_all[inset])

    return [Plot.add_inset_axes(axes[i], inset_position, fontsize=fontsize) for i in range(n)]
        


def foo(Axes, arg2, libraries, insets, NrsAxes, inset_position=None, fontsize=None, **P):

    inds_subplots, inds_axes_, NrsAxes_all = arg2 

    for (subplot_nr, library_i) in enumerate(inds_subplots): 
    
        axes = get_axes(Axes, inds_axes_, subplot_nr)
    
        plot_one(axes, libraries[library_i], fontsize=fontsize, **P)
    
        if library_i in insets.keys():
    
    
            axes_ = add_inset_axes(NrsAxes[subplot_nr], NrsAxes_all, insets[library_i], axes, inset_position, fontsize)
    
    
            ax = plot_one_timed(axes_, libraries[insets[library_i]],
                    **inset_sizes(inset_position, P), 
                    show_colorbar=False)
    
    
            Plot.disable_labels(ax)
    
            Plot.disable_labels(axes_) 



def merge_parameters(P, *Ps):

    print()
    
    if len(P)>0: 
        print(P,"\n") 
    
    for P_ in Ps:
    
        if len(P_)>0: 
            print(P_,"\n")
    
            P.update(P_) 
    
    return P

def P_from_obj(obj, params, single_params, read_slid, insets):

    P = merge_parameters(
                get_paramsuser(obj, params), 
                *(r(obj) for r in read_slid),
                single_params)

    P["inset_position"] = get_inset_pos(insets, obj, sliders.insets()[1])

    return P 

#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#


def init_plot_0(libraries, initial_data=dict(), insets=dict()):

    insets = {k-1:v-1 for (k,v) in insets.items()} # julia 

    libraries = [[import_module(lib),f,t] for (lib,f,t) in libraries]
   
    NrsAxes_all = [lib.nr_axes(**initial_data) for (lib,f,t) in libraries]
  
    inds_subplots = np.setdiff1d(range(len(NrsAxes_all)), list(insets.values()))
   
    NrsAxes = np.array(NrsAxes_all)[inds_subplots]
   
    inds_axes_ = np.cumsum(np.append(0, NrsAxes))

    return ((inds_subplots, inds_axes_, NrsAxes_all), 
            (NrsAxes, libraries, initial_data, insets,
                nrowscols(sum(NrsAxes), **initial_data))
            )

def baz(f_figure, nr_rc, params, insets, other_sliders, **initial_data):

    fig = PlotPyQt.Figure(f_figure, *nr_rc, tight=True)

    for (i,(name,values)) in enumerate(zip(*params)):
    
        add_widget(fig, i, name, values)

    fig.new_row() 

    for add_slid_i in other_sliders:
        add_slid_i(fig, **initial_data)

    if len(insets)>0:

        sliders.insets()[0](fig, **initial_data)

    fig.show()


#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#

def get_inset_pos(insets, obj=None, read_sliders_insets=None, inset_position=None,
        **kwargs):

    if (inset_position is not None) or (len(insets)==0):
        return inset_position 

    if obj is None:
            
        return Plot.inset_positions(Plot.inset_positions()[0], 0.3)

    else:

        return read_sliders_insets(obj)


        



def init_plot(*args, **kwargs):

    arg2, (NrsAxes, libraries, initial_data, insets, nr_rc) = init_plot_0(*args, **kwargs)


    def figure(Axes, printP=True, inset_position=None, **P): 
       
        if printP: print("\n",P,"\n") 
        
        inset_position = get_inset_pos(insets, **P)

        foo(Axes, arg2, libraries, insets, NrsAxes, inset_position, **P)

    return figure, insets, nr_rc 

      # ----------------------------- #



def plot_direct_frominit(figure, insets, nr_rc, 
        figsize=None, 
        fignum=0,
        tight_layout=True,
        **kwargs):

    if figsize is None:

        figsize = np.array(nr_rc)[::-1]

        figsize = figsize/figsize.max() * 8 
        
    fig,Ax = plt.subplots(*nr_rc, figsize=figsize, num=fignum)
    
    figure(Ax, **kwargs)

    if tight_layout:
        fig.tight_layout() 
    
    plt.show() # ??

    return fig,Ax 




#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#


def plot_frominit(params, libraries, figure, insets, nr_rc, 
        extra_sliders=[],
        initial_data=dict()):

    params, single_params = get_single_elements(params)

    
    libraries = [[import_module(lib),f,t] for (lib,f,t) in libraries]  

    add_slid,read_slid = bar(libraries, extra_sliders)


    def figure_pyqt(obj, Fig, Axes):

        P = P_from_obj(obj, params, single_params, read_slid, insets)

        return figure(Axes, printP=False, **P)


    

    baz(figure_pyqt, nr_rc, params, insets, add_slid, **initial_data)
   
#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#



    
def plot_(params, libraries, extra_sliders=[], initial_data=dict(), insets=dict()):

    data = init_plot(libraries, initial_data, insets)
   
    plot_frominit(params, libraries, *data, extra_sliders, initial_data)

    
    
    




#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#

def bar(libraries, extra_sliders):

    extra_slid = [getattr(sliders,s) for s in extra_sliders]

    lib_slid = []

    for (lib,f,t) in libraries:

        for S in get_local_sliders(lib):

            if S not in extra_slid: lib_slid.append(S)

    add_extra_slid,read_extra_slid = sliders.addread_sliders(extra_slid) 

    add_lib_slid,read_lib_slid = sliders.addread_sliders(lib_slid,withfont=False) 

    return (add_extra_slid,add_lib_slid),(read_extra_slid,read_lib_slid)





def plot(params, libraries, 
        extra_sliders=[],
        initial_data=dict(), insets=dict()):

    params, single_params = get_single_elements(params)

    arg2, (NrsAxes, libraries, initial_data, insets, nr_rc) = init_plot_0(libraries, initial_data, insets)


    add_slid,read_slid = bar(libraries, extra_sliders)


    # ---------------------------------- #

    def figure(obj, Fig, Axes): 
        
        P = P_from_obj(obj, params, single_params, read_slid, insets)

        foo(Axes, arg2, libraries, insets, NrsAxes, **P)

      # ----------------------------- #
   
    baz(figure, nr_rc, params, insets, add_slid, **initial_data)










