import Plot,Algebra,Utils
from plothelpers import *
from sliders import *
from LocalObservables import common_sliders, common_sliders0

from Z_vsX_vsY import plot as plot0


local_sliders = common_sliders0 + [choose_energy] + common_sliders1




#===========================================================================#
#
#   plot
#
#---------------------------------------------------------------------------#

def plot(Ax, xline=None, yline=None, 
        lobsmin=None, lobsmax=None, length=None, **kwargs):



    plot0(Ax, zmin=lobsmin, zmax=lobsmax, yline=length, **kwargs) 







