import Scatter 
import numpy as np 
import matplotlib.pyplot as plt 
import time 






def get_plotdata(*args,**kwargs):

    time.sleep(2)

    X = np.linspace(0,2,500)

    Y = (np.random.rand(len(X)) - 0.5)*10

    return {"x":X, "y":Y}


if __name__ == '__main__': 

    fig,ax = plt.subplots()
    
    Scatter.plot([ax], get_plotdata, ylim=[-3,1])
    
    plt.show()
    












