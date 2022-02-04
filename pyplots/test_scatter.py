import Scatter 
import numpy as np 
import matplotlib.pyplot as plt 

A = np.random.rand(10)


print(A) 

print(Scatter.restrict(A,None))

print(Scatter.restrict(A,[None]))

print(Scatter.restrict(A,(0.2,0.8)))

print(Scatter.restrict(A,(-1,3))) 



x,y,z = Scatter.mask(np.linspace(0,1,20),[0.2,0.8],np.linspace(3,4,20),[3.5,5],np.random.rand(20)) 

print(x)
print(y)
print(z)

x,y,z = Scatter.mask(np.linspace(0,1,20),[-1,2],np.linspace(3,4,20),[-1,15],np.random.rand(20)) 

print(x)
print(y)
print(z)



print()
print()
print() 





fig,ax = plt.subplots()



def get_plotdata(*args,**kwargs):


    X = np.linspace(0,2,500)

    Y = (np.random.rand(len(X)) - 0.5)*10

    return {"x":X, "y":Y}



Scatter.plot([ax], get_plotdata, ylim=[-3,1])

plt.show()













