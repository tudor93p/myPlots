import Scatter 
import numpy as np 
import matplotlib.pyplot as plt 
import time 






def get_plotdata(*args,**kwargs):

#    time.sleep(2)

    X = np.linspace(0,2,40)

    Y = (np.random.rand(len(X)) - 0.5)*10

    Y.sort()

    return {"x":X, "y":Y,
            "z":np.random.rand(len(X)),
            "label":"test",
            "zlabel":"rand",
            "yline":0,

            }

def get_kwargs():

    return {"ylim": [-2,1],
            }


if __name__ == '__main__': 

    fig,ax = plt.subplots()
    
    Scatter.plot([ax], **get_plotdata(), **get_kwargs())
    
    plt.show()
    












