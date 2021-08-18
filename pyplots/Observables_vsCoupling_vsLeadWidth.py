from Observables_vsX_vsY import plot as plot0
from Observables_vsX_vsY import common_sliders, nr_axes


add_sliders,read_sliders = addread_sliders(*common_sliders, choose_energy)

def plot(Ax, get_plotdata, Lead_Width=None, Lead_Coupling=None, enlim=None, 
                yline=None, xline=None, **kwargs):

    plot0(Ax, get_plotdata, yline=Lead_Width, xline=Lead_Coupling, **kwargs)


    
    
    




