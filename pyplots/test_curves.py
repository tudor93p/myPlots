import Curves_yofx 
import numpy as np 
import matplotlib.pyplot as plt 
import time 






def get_plotdata(*args,**kwargs):

#    time.sleep(2)

    X = np.linspace(0,2,5)

    Y = (np.random.rand(len(X)) - 0.5)*10

    return {"x":X, "y":Y,
#            "z":np.random.rand(len(X)),
            "label":"test",
#            "zlabel":"rand",
            "yline":0,

            }

def get_kwargs():

    return {"ylim": [-3,1],
            }


if __name__ == '__main__': 

    fig,ax = plt.subplots()
    
    Curves_yofx.plot([ax], **get_plotdata(), **get_kwargs())
    
    plt.show()
    












