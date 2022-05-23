import Z_vsX_vsY
import numpy as np  
import time 

import matplotlib.pyplot as plt 


xmin = 0 +np.random.rand()
xmax = 2 + np.random.rand()
nx = 15 + np.random.randint(15)

ymin = 2 + np.random.rand()
ymax = 3 + np.random.rand()
ny = 10 + np.random.randint(10) 



print(xmin,xmax,nx)
print(ymin,ymax,ny) 

def get_plotdata(*args,**kwargs):

    X = np.linspace(xmin,xmax,nx)

    Y = np.linspace(ymin,ymax,ny)
 
    Z = np.random.rand(nx,ny)

    kx = np.pi/nx/2
    ky = np.pi/ny/3

    for j in range(ny):
        for i in range(nx):

            Z[i,j] = np.sin(i*kx)*np.cos(j*ky)

    return {"x":X, "y":Y, "z":Z,
            "xlabel":"$x$",
            "ylabel":"$y$",
            "x_plot":[X[nx//2-1],X[nx//2+1]],
            "y_plot":[Y[ny//2-1],Y[ny//2+1]],
            }

    

if __name__ == '__main__': 

    fig,ax = plt.subplots()


    data = get_plotdata()

    Z_vsX_vsY.plot([ax], get_plotdata, 
                        xline = data["x"][nx//2-1],#np.random.choice(data["x"]),
                        yline = data["y"][ny//2+1],#np.random.choice(data["y"]),
#                        xlim = [xmin,xmax],
#                        ylim = [ymin,ymax],
                        )
            
    plt.show()
    

