from plothelpers import *#getlim 
import numpy as np
from numpy.random import rand 



for dat in [
            None,
            [],
            [None],
            [None,rand(3)],
            rand(3),
            [rand(2),rand(5)],
            rand(0),
            rand(),
            [rand(0),rand(7)],
            rand(0,5),
            [rand(2),rand(4,6),rand(0)],
            [rand(0),rand(0),3,rand(1)],
            ]:
    print()
    print("Data:",dat)

    print("Limits:",getlim(dat))


exit()

print() 


xlim=None
ylim=[-0.8,0.8]
zlim=[None, None]

data = [np.array([None])]
limits = [[None, None]]


print(deduce_axislimits(data,limits))


print(deduce_axislimits([[None,0.3]],[None]))
