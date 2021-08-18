from importlib import import_module
import numpy as np
from plothelpers import *
import PlotPyQt
import time
import sliders






def plot(params, libraries, initial_data=dict(), insets=dict()):

    params, single_params = get_single_elements(params)


    insets = {k-1:v-1 for (k,v) in insets.items()}


    libraries = [[import_module(lib),f,t] for (lib,f,t) in libraries]
   
    NrsAxes_all = [lib.nr_axes(**initial_data) for (lib,f,t) in libraries]
  

    inds_subplots = np.setdiff1d(range(len(NrsAxes_all)), list(insets.values()))
   
    NrsAxes = np.array(NrsAxes_all)[inds_subplots]
   
    
    inds_axes_ = np.cumsum(np.append(0, NrsAxes))

    add_sliders_insets, read_sliders_insets = sliders.insets()



    def figure(obj, Fig, Axes): 
        
        if np.ndim(Axes)==0:
            Axes = np.array([Axes])

   
        def get_axes(subplot_nr):

            inds = (inds_axes_[subplot_nr], inds_axes_[subplot_nr+1]) 
            
            return Axes[np.unravel_index(np.arange(*inds), Axes.shape)]




        P = get_paramsuser(obj, params)

        print("\n",P,"\n")
   
        for P_ in [get_paramsplot(obj, libraries), single_params]:

            print(P_,"\n")

            P.update(P_)


        fontsize = P["fontsize"]
				
                                
                                
        
        
        if len(insets)>0:

            inset_position = read_sliders_insets(obj)


#        for (inds,(lib,f,title)) in zip(inds_axes(),libraries):

        for (subplot_nr, library_i) in enumerate(inds_subplots):

            axes = get_axes(subplot_nr)



            (lib, f, title) = libraries[library_i]
           

            start0 = time.time()

            lib.plot(axes, f, **P)

            print(title+": "+str(int(time.time()-start0))+"s\n")



            if len(axes)==1:

                axes[0].set_title(
                                printable_string(title), fontsize=fontsize)


            Plot.set_fontsize(axes, fontsize)





#        for (subplot_nr, library_i) in enumerate(inds_subplots):
#
#            axes = get_axes(subplot_nr)

            if library_i in insets.keys():

                #left, bottom, width, height

                (lib_, f_, title_) = libraries[insets[library_i]]

                n = min(NrsAxes[subplot_nr], NrsAxes_all[insets[library_i]])


                axes_ = [Plot.add_inset_axes(axes[i], inset_position, fontsize=fontsize) for i in range(n)]

                start0_ = time.time()

                ax = lib_.plot(axes_, f_, **inset_sizes(inset_position, P), show_colorbar=False)


                print(title_+": "+str(int(time.time()-start0_))+"s\n")

                            # lib_.plot might create twin axes 

                Plot.disable_labels(ax)
                Plot.disable_labels(axes_)





      # ----------------------------- #
   
    
    fig = PlotPyQt.Figure(figure, *nrowscols(sum(NrsAxes), **initial_data),
                                        tight=True)
    
   
    for (i,(name,values)) in enumerate(zip(*params)):
    
        add_widget(fig, i, name, values)

    fig.new_row()
    
    for (lib,f,t) in libraries:

        lib.add_sliders(fig,**initial_data)
    

    if len(insets)>0:

        add_sliders_insets(fig,**initial_data)
        
        


    
    
    
    
    fig.show()

