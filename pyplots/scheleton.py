from importlib import import_module
import numpy as np
from plothelpers import *
import PlotPyQt
import time
import sliders
import matplotlib.pyplot as plt 
import json 




#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#



def get_axes(Axes, inds_axes_, subplot_nr):

    inds = (inds_axes_[subplot_nr], inds_axes_[subplot_nr+1]) 



    if np.ndim(Axes)==0: 

        assert inds[0]==inds[1]-1==0 
        
        return np.array([Axes])
        
    return Axes[np.unravel_index(np.arange(*inds), Axes.shape)]






#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#



#def combine_data_and_P(f, P):
#
#    data = f(P)
#
#    data.update(P)
#
#    return data  


def plot_one_timed(axes, lib, f, title, inset=False, **P):
 
    start0 = time.time() 
   
    data = f(P)

    data.update(P)

    out = plot_one_fromdata(axes, lib, data, title, inset)


    print(title+": "+str(int(time.time()-start0))+"s\n") 

    return out 





def plot_one_fromdata(axes, lib, data, title, inset=False):
 
    if isinstance(lib,str):
        return plot_one_fromdata(axes, import_module(lib), data, title, inset)



    if inset:
        Plot.disable_labels(lib.plot(axes, show_colorbar=False, **inset_kwargs(data)))
        Plot.disable_labels(axes) 

    else:
        lib.plot(axes, **data)

        if len(axes)==1:
    
            axes[0].set_title(printable_string(title),
                                fontsize=data.get("fontsize",None))

        Plot.set_fontsize(axes, data.get("fontsize",None))

    return (lib.__name__, data, title)





#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#










def add_inset_axes(axes, NrsAxes_all, inset, inset_position, fontsize):

    n = min(len(axes), NrsAxes_all[inset])


    return [Plot.add_inset_axes(axes[i], inset_position, fontsize=fontsize) for i in range(n)]
        

#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#



def draw_subplots(Axes, 
        libraries, 
        numbering_subplots, 
        insets, 
        inset_position=None, 
        record_data=False,
        **P):

    components = dict() 

    inset_args = [inset_position, P.get("fontsize",None)]


    inds_subplots, inds_axes_, NrsAxes_all = numbering_subplots  

    for (subplot_nr, i) in enumerate(inds_subplots): 
    
        axes = get_axes(Axes, inds_axes_, subplot_nr)
    
        lib_out = plot_one_timed(axes, *libraries[i], **P)
        
        if record_data:
            components[str(i)] = lib_out 

        if i in insets.keys():
    
            j = insets[i]

            axes_ = add_inset_axes(axes, NrsAxes_all, j, *inset_args)
   
            lib_out_ = plot_one_timed(axes_, *libraries[j], inset=True, **P,) 

            if record_data:
                components[str(j)] = lib_out_ 


    if not record_data: return {}


    return {
            "numbering_subplots":numbering_subplots,
            "insets":insets,
            "inset_args": inset_args,
            "components": components
            }


def data_from_plot0(i0, **kwargs):

    numbering_subplots, (components, initial_data, insets, nr_rc) = i0

    fontsize = [c[1]["fontsize"] for c in components if "fontsize" in c[1]][0]

    i_p = [c[1]["inset_position"] for c in components if "inset_position" in c[1]]


    inset_args = [get_inset_pos(insets, i_p[0] if len(i_p)>0 else None), fontsize]


    out = {"numbering_subplots":numbering_subplots,
            "insets":insets,
            "inset_args":inset_args,
            "components": {str(int(i)):[lib.__name__,data,t] for (i,(lib,data,t)) in enumerate(components)},
            "nr_rc":nr_rc}

    out.update(kwargs)

    return out 






#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#



def draw_subplots_fromdata(
        Axes, 
        inset_args=None,
        numbering_subplots=None,
        insets=dict(),
        components=None,
        **kwargs
        ):


    inds_subplots, inds_axes_, NrsAxes_all = numbering_subplots  

    for (subplot_nr, i) in enumerate(inds_subplots): 
    
        axes = get_axes(Axes, inds_axes_, subplot_nr)
    
        plot_one_fromdata(axes, *components[str(i)])

        if i in insets.keys():
    
            j = insets[i]

            axes_ = add_inset_axes( axes, NrsAxes_all, j, *inset_args)
   
            plot_one_fromdata(axes_, *components[str(j)], inset=True) 

    return 





#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#


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

    P["record_data"] = obj.get_checkbox("output_figure") 

    return P 

#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#





def init_plot_0(libraries, initial_data=dict(), insets=dict(),
    insets_from_julia=True, **kwargs,
        ):

    initial_data.update(kwargs) 

    if insets_from_julia:
        insets = {k-1:v-1 for (k,v) in insets.items()}

    libraries = [[import_module(lib),f,t] for (lib,f,t) in libraries]
   
    NrsAxes_all = [lib.nr_axes(**initial_data) for (lib,f,t) in libraries]
  
    inds_subplots = np.setdiff1d(range(len(NrsAxes_all)), list(insets.values()))
   
    NrsAxes = np.array(NrsAxes_all)[inds_subplots]
   
    inds_axes_ = np.cumsum(np.append(0, NrsAxes))


    return ((inds_subplots, inds_axes_, NrsAxes_all), 
            (libraries, initial_data, insets,
                nrowscols(sum(NrsAxes), **initial_data))
            )


#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#


def pyqt_fig_show(f_figure, nr_rc, params, insets, other_sliders, 
        windowtitle=None,
        **initial_data):

    fig = PlotPyQt.Figure(f_figure, *nr_rc, tight=True, windowtitle=windowtitle)

    for (i,(name,values)) in enumerate(zip(*params)):
    
        add_widget(fig, i, name, values)

    fig.new_row() 

    for add_slid_i in other_sliders:
        add_slid_i(fig, **initial_data)

    if len(insets)>0:

        sliders.insets()[0](fig, **initial_data) # add

    fig.show()

    return 



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
#        print("here") 
#        print(Plot.inset_positions()[0])
#        print(Plot.inset_positions(Plot.inset_positions()[0], 0.3))
            
        return Plot.inset_positions(Plot.inset_positions()[0], 0.3)

    else:

        return read_sliders_insets(obj)


        



def init_plot(*args, **kwargs):

    numbering_subplots, (libraries, initial_data, insets, nr_rc) = init_plot_0(*args, **kwargs)


    def figure(Axes, printP=True, inset_position=None, fontsize=12, **P): 
       
        if printP: print("\n",P,"\n") 

        return draw_subplots(Axes, 
                libraries, 
                numbering_subplots, 
                insets, 
                get_inset_pos(insets, **P),
                fontsize=fontsize, **P)

    return figure, initial_data, insets, nr_rc 

      # ----------------------------- #


def default_figsize(nr_rc):
    
    figsize = np.array(nr_rc)[::-1]

    return figsize/figsize.max() * 8 




def plot_direct_frominit(figure, 
        slider_initial_data, ## ignored 
        insets, 
        nr_rc, 
        figsize=None, 
        fignum=0,
        tight_layout=True,
        sharex=False,
        sharey=False,
        **kwargs):

    if figsize is None:
        figsize = default_figsize(nr_rc)
        
    fig,Ax = plt.subplots(*nr_rc, 
            figsize=tuple(x/2.54 for x in figsize),
            sharex=sharex, sharey=sharey)
    
    out = figure(Ax, **kwargs) 

##########
    
# initial_data

    out["nr_rc"] = nr_rc 
    out["tight_layout"] = tight_layout 
    out["figsize"] = figsize 
    out["sharex"] = sharex 
    out["sharey"] = sharey 


########## 

    if tight_layout:
        fig.tight_layout() 
    
    plt.show() # ??

    return out#,fig,Ax  




#===========================================================================#
#
#
#
#---------------------------------------------------------------------------# 

def components_asarray(data):
    
    for c in data["components"].values():
        component_asarray(c)

    return data 


def component_asarray(c):

    for (k,v) in c[1].items():
        
        if k in ['nodes','dRs','x','y','z']:
        
            c[1][k] = np.asarray(v)

    return c 


def keep_components(data,i_comps):

    if i_comps is None: 
        return data 
        
    i_del = set(data["components"].keys()).difference(set(map(str,i_comps)))

    for i in i_del:
        del data["components"][i]

    return data 

def update_components(data,comp_update):

    if len(comp_update)>0:
        for i in data["components"].keys():
            data["components"][i][1].update(comp_update)

    return data 


def load_data(fnjson,i_comps=None,
        comp_update={}):

    with open(fnjson,"r") as f: 
        data = json.load(f) 

    keep_components(data, i_comps)

    update_components(data, comp_update)

    components_asarray(data)   

    return data 


def load_components(fnjson,i_comps,comp_update={}):

    with open(fnjson,"r") as f: 
        data = json.load(f) 

    keep_components(data, i_comps)
    
    update_components(data, comp_update)
    
    components_asarray(data)  

    return [data["components"][str(i)] for i in i_comps]






def plot_fromfile(fnjson, **kwargs):

    data = load_data(fnjson)

    return fig_fromdata(**data, **kwargs)



def default_nrrc(numbering_subplots=None, **kwargs):

    return nrowscols(len(numbering_subplots[2]))






def fig_fromdata(
        nr_rc=None,
        figsize=None, 
        tight_layout=True,
        sharex=False,
        sharey=False,
        **loaded_data):

    if nr_rc is None:
        nr_rc = default_nrrc(**loaded_data)
    if figsize is None:
        figsize = default_figsize(nr_rc)




    fig,Ax = plt.subplots(*nr_rc, 
            figsize=tuple(x/2.54 for x in figsize),
            sharex=sharex, sharey=sharey)

    out = draw_subplots_fromdata(Ax, **loaded_data)
    
    if tight_layout:
        fig.tight_layout() 

#    plt.show()

    return (fig,Ax),out 


#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#


def plot_frominit(params, libraries, 
        figure, initial_data, insets, nr_rc, # from init_plot
        extra_sliders=[],
        ):

    params, single_params = get_single_elements(params)

    
    libraries = [[import_module(lib),f,t] for (lib,f,t) in libraries]  

    add_slid,read_slid = get_addread_slids(libraries, extra_sliders)


    def figure_pyqt(obj, Fig, Axes):

        P = P_from_obj(obj, params, single_params, read_slid, insets)

        return figure(Axes, printP=False, **P)


    

    return pyqt_fig_show(figure_pyqt, nr_rc, params, insets, add_slid, **initial_data)
   
#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#



    
def plot_(params, libraries, extra_sliders=[], initial_data=dict(), insets=dict(), **kwargs):

    data = init_plot(libraries, initial_data, insets, **kwargs)
   
    return plot_frominit(params, libraries, *data, extra_sliders)

    
    
    




#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#

def get_addread_slids(libraries, extra_sliders):

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
        initial_data=dict(), insets=dict(), **kwargs):

    params, single_params = get_single_elements(params)

    numbering_subplots, (libraries, initial_data, insets, nr_rc) = init_plot_0(libraries, initial_data, insets, **kwargs)


    add_slid,read_slid = get_addread_slids(libraries, extra_sliders)


    # ---------------------------------- #

    def figure(obj, Fig, Axes): 
        
        P = P_from_obj(obj, params, single_params, read_slid, insets)

        return draw_subplots(Axes, libraries, numbering_subplots, insets, **P)

      # ----------------------------- #
   
    return pyqt_fig_show(figure, nr_rc, params, insets, add_slid, **initial_data)










