import numpy as np

from LocalObservables import plot as plot0
from LocalObservables import common_sliders, local_sliders 



def nr_axes(nrowcol,**kwargs):
   
    return np.prod(nrowcol)


#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#

def plot(Ax, 
        plotxdata, plotx, plotxlabel, 
        fontsize=12, **kwargs):


    for (data, title, ax) in zip(plotxdata, plotx, Ax):

        plot0([ax], **data, **kwargs, fontsize=fontsize)
        
        title = str(plotxlabel) + " = " +str(title) 

        ax.set_title(str(title), fontsize=fontsize)
    
    
    




