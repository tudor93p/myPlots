import numpy as np,time ,Plot
import Utils 
import VectorField
import Curves_yofx
import PlotPyQt
import matplotlib.pyplot as plt
from sliders import fontsizes
import time 




add_font, read_font = fontsizes()



N = 15 

s = np.linspace(-1,1,N)*1.9

X,Y=np.meshgrid(s,s)

XYZs = np.hstack((  np.reshape(X,(-1,1)),
                    np.reshape(Y,(-1,1)),
                    np.zeros((np.prod(X.shape),1)),
                    ))


def vector_field_1(R):

    x,y = R 

    return 0.2*(-x,y,0)




def sincos(a):

    return np.sin(a),np.cos(a)



def R(rho, theta, phi):

    st,ct = sincos(np.reshape(theta,-1))
    sp,cp = sincos(np.reshape(phi,-1))
   
    def outerprod(a,b):

        return np.reshape(a[:,np.newaxis]*b[np.newaxis,:],-1)


    return np.concatenate(( outerprod(st,cp)[:,np.newaxis],
                            outerprod(st,sp)[:,np.newaxis],
                            outerprod(ct,np.ones_like(sp))[:,np.newaxis]),
                            axis=1)*rho

def E(obs_points, sources, restrict=None):

    D = obs_points[:,np.newaxis,:] - sources[np.newaxis,:,:]

 #   [obs_point,charge,dim] #differences 

    d = np.linalg.norm(D, axis=2, keepdims=True)**3 

#    [obs_point, charge, 1] # distances

    out = lambda aD,ad : 0.5/len(sources)*np.sum(aD/ad,axis=1)
#    out = lambda aD,ad : 0.1/len(sources)*np.sum(aD,axis=1)

    if restrict is not None:

        i = np.all(d>restrict, axis=(1,2))

        return obs_points[i,0:2],out(D[i,:,:], d[i,:,:])

    return obs_points[:,0:2],out(D,d)


def get_plotdata(kwargs):

#    time.sleep(5)
    out = {}
   
    n = kwargs.get("n",3)

    theta = np.linspace(0, np.pi, max(1,n//2), endpoint=False) #+ np.random.rand()*np.pi 

#    theta = np.pi/2

    phi = np.linspace(0,2*np.pi,n,endpoint=False) #+ np.random.rand()*2*np.pi

    charges = R(1, theta, phi) 

#    print("charges",charges.shape)
    theta2 = np.linspace(0, np.pi, 50, endpoint=False) #+ np.random.rand()*np.pi 

#    theta2 = np.pi/2

    phi2 = np.linspace(0,2*np.pi,100,endpoint=False) #+ np.random.rand()*2*np.pi

    surface = R(0.8, theta2, phi2) 

#    print("surface",surface.shape)

    out["surface"] = surface
    out["charges"] = charges
   

#    out["nodes"] = Utils.vectors_of_integers(2,int(n))

#    out["dRs"] = np.random.rand(*out["nodes"].shape)-0.5

#    out["label"] = "Random arrows"





    out["nodes"], out["dRs"] = E(XYZs, charges, 0.01)
  
#    print(out["dRs"])
#    Es = E(surface, charges)[1]


#    out["ylabel"]= "test"
#    print("E on surface",Es.shape)

#    print(np.sum(surface*Es))


    return out 















def get_plotdata2(kwargs):

    out = {}
   
    n = kwargs.get("n",3)

    out["x"] = np.linspace(-n,n,100)

    out["y"] = 1 + np.sin(out["x"]) + np.exp(-out["x"]**2)*2

    out["label"] = "1+sin+exp"

    return out 


def figure(obj, Fig, Axes):



    P = {"n":obj.get_slider("n"),
            "arrow_headwidth":0.06,
            "arrow_headlength":0.1,
            "arrow_width":0.015,
            }


    for lib in [VectorField]:#, Curves_yofx]:
        P.update(lib.read_sliders(obj))

    P["atomsize"] = 0.25

    P.update(read_font(obj))

    data = get_plotdata(P)

    ax= Axes 
    VectorField.plot([ax], lambda aux: data, **P)
#    Curves_yofx.plot(Axes[1:2], get_plotdata2, **P)

    fontsize = P["fontsize"]

    ax.scatter(*data["charges"].T[:2], zorder=10000, c='red')



    #left, bottom, width, height
   
    subpos = [0.2, 0.6, 0.3, 0.3]
   

#    newax2 = Plot.add_inset_axes(Axes[1], subpos, fontsize=fontsize)

#    fontsize1 = Plot.inset_fontsize(subpos, fontsize)

#    VectorField.plot([newax2], get_plotdata, **{**P, "fontsize":fontsize1})



#    newax = Plot.add_inset_axes(Axes[0], subpos, fontsize=fontsize)

#    Curves_yofx.plot([newax], get_plotdata2, **{**P, "fontsize":fontsize1})


#    newax.set_title("title1",fontsize=fontsize1)

    for ax in np.reshape(Axes,-1):
        ax.set_aspect(1)
        ax.tick_params(labelsize=fontsize)
    
        ax.xaxis.label.set_size(fontsize)

        ax.yaxis.label.set_size(fontsize) 

if __name__ == '__main__': 


    fig = PlotPyQt.Figure(figure, 1, 1)
    
    for lib in [VectorField]:#, Curves_yofx]:
        lib.add_sliders(fig)
    
    add_font(fig)
    
    
    fig.add_slider(label="Size",key="n",vs=range(1,150))
    
    fig.show()
    
    
