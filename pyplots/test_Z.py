import Z_vsX_vsY
import numpy as np  
import time 

import matplotlib.pyplot as plt 

def get_plotdata(*args,**kwargs):

    time.sleep(2)

    X = np.linspace(0,2,23)

    Y = np.linspace(2,3,13)

    Z = np.random.rand(len(X),len(Y))

    return {"x":X, "y":Y, "z":Z,
            "xlabel":"$x$",
            "ylabel":"$y$"}

if __name__ == '__main__': 

    fig,ax = plt.subplots()
    
    Z_vsX_vsY.plot([ax], get_plotdata, xline=0.2, yline=2.5)
    
    plt.show()
    

