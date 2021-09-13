from sliders import *

from Scatter import nr_axes 

from Curves_yofx import plot as plot1
from Scatter import plot as plot2

from Curves_yofx import common_sliders as common_sliders1
from Scatter import common_sliders as common_sliders2


common_sliders = [saturation, choose_k, choose_energy]


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

    plot1(*args, **kwargs)

    plot2(*args, **kwargs)









