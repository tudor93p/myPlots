import PyPlot 


x = -20:20 


nr_periods = 4 

T = (x[end]-x[1])/nr_periods 


omega = 2pi/T 
@show T 
@show omega 

phi0 = rand()*2pi 
y0 = rand()*0

y = sin.(omega*x .+ phi0) .+ y0



fig,(ax1,ax2)=PyPlot.subplots(2)

ax1.plot(x,y)


k,A = myPlots.Transforms.fourier_abs(x,y) 
ax2.plot(2pi./k,A)

@show myPlots.Transforms.argmax_fourier_abs(x,y)

@show 2pi/k[argmax(A)]

@show 2pi./k





