from sliders import *

from Scatter import nr_axes 

from Curves_yofx import plot as plot1
from Scatter import plot as plot2

from Curves_yofx import common_sliders as common_sliders1
from Scatter import common_sliders as common_sliders2
from Hamilt_Diagonaliz import common_sliders as common_sliders3

common_sliders = [saturation, choose_energy] + common_sliders3



add_sliders, read_sliders = addread_sliders(*common_sliders1,
                                            *common_sliders2,
                                            *common_sliders,

                                            )


#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#


def plot(*args, **kwargs):

    plot1(*args, zorder0=0, **kwargs)

    plot2(*args, zorder0=1000, **kwargs)









