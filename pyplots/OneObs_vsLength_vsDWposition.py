from OneObs_vsX_vsY import plot as plot0
from OneObs_vsX_vsY import common_sliders, nr_axes, addread_sliders


def plot(Ax, get_plotdata, ylim=None, enlim=None,
                    length=None, SCDW_position=None,
                    xline=None, yline=None, **kwargs):

    plot0(Ax, get_plotdata, yline=SCDW_position, xline=length, **kwargs)


    
    
    




