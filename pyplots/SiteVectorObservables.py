from plothelpers import *
from sliders import *
from VectorField import plot as plot0, common_sliders as common_sliders0
from VectorField import nr_axes



common_sliders = [sitevector_observables, obs_index]

add_sliders, read_sliders = addread_sliders(*common_sliders0,
                                            *common_sliders,
                                            energy_zoom,
                                            choose_energy,
                                            )


#===========================================================================#
#
#   Plot
#
#---------------------------------------------------------------------------#



def plot(Ax, get_plotdata, **kwargs):


    plot0(Ax, get_plotdata, **kwargs) 

   
    for ax in Ax:
        ax.set_aspect(1)
        












