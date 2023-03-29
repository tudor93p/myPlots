import numpy as np

from Observables_vsLength_vsWidth import plot as plot0
from Observables_vsLength_vsWidth import local_sliders 



def nr_axes(nrowcol,**kwargs):
   
    return np.prod(nrowcol)


#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#

#refine ...

def plot(Ax, SCDW_width=None, Lead_Width=None, fontsize=12, 
                            **Data):

    Z = Data.pop("z")

    def title(c,a):
        
        return "=".join([Data[f"plot{c}label"], str(Data[f"plot{c}"][a])])




    for ((i,j), ax) in zip(np.ndindex(*Z.shape[-2:]), Ax):
      
        data = {**Data, "z": Z[:,:,i,j]}

        plot0([ax], lambda aux: data, fontsize=fontsize, **Data)

        ax.set_title(", ".join([title(*I) for I in zip("xy",(i,j))]),
                                                    fontsize=fontsize)
    
    
    




