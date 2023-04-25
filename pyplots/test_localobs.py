import LocalObservables  
import numpy as np 
import matplotlib.pyplot as plt 

def FlatOuterSum(U,V):

    return np.vstack([np.add.outer(U[i,:],V[i,:]).reshape(-1) for i in range(U.shape[0])])



def get_plotdata():
    
    nr_at = 400

    x = np.sort(np.random.rand(nr_at))

    x = np.arange(-nr_at//2,nr_at-nr_at//2)


    atoms = np.vstack((x,np.zeros(nr_at)))
    
    a = 1 #np.max(atoms)  

    UCs = np.random.rand(2,max(1,nr_at//3))

    y = np.arange(max(1,nr_at//3))

    UCs = np.vstack((np.zeros(len(y)),y))

    nr_uc = UCs.shape[1] 

    color = np.random.rand(nr_at)
    color.sort()
        
    xy = FlatOuterSum(atoms,UCs)


    z = np.array([color for i in range(nr_uc)]).T.reshape(-1)


    out = { "localobs": "LocalDOS",
            "xy": xy,
            "z": z,
            "atomsize":4,
            "fontsize":10,
            "cmap": "copper_r",
            "kwargs_colorbar": {
                "orientation" : "horizontal",
                "fraction" : 0.05,
                "rotation" : 0,
                "labelpad" : -4,
					#pad=0.2,
                }
            }

    return out 




if __name__ == '__main__': 

    fig,ax = plt.subplots()
    
    LocalObservables.plot([ax], **get_plotdata())
    
    plt.show()
    






