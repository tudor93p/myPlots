from Observables_vsX_vsY import plot as plot0
from Observables_vsX_vsY import common_sliders, nr_axes


local_sliders = common_sliders + [choose_energy]



#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#


def plot(Ax, Lead_Width=None, Lead_Coupling=None, enlim=None, 
                yline=None, xline=None, **kwargs):

    plot0(Ax, yline=Lead_Width, xline=Lead_Coupling, **kwargs)


    
    
    




