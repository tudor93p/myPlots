#from plothelpers import *
from sliders import *
from Curves_yofx_atE import plot as plot0, common_sliders as common_sliders0

from Curves_yofx_atE import nr_axes

from Hamilt_Diagonaliz import common_sliders as common_sliders1



add_sliders, read_sliders = addread_sliders(*common_sliders0, *common_sliders1)


#===========================================================================#
#
#   Plot
#
#---------------------------------------------------------------------------#



def plot(Ax, get_plotdata, ylim=None, opermin=None, opermax=None, **kwargs):



    plot0(Ax, get_plotdata, ylim=[opermin,opermax], **kwargs) 

    

        












