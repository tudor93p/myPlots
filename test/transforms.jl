T = myPlots.Transforms
using Constants: NR_ENERGIES
import PyPlot
import myLibs:Utils
using BenchmarkTools: @btime


@show T.get_SamplingVars_(Dict(), "Energy")
@show T.get_SamplingVars_(Dict("Energy"=>0.1), "Energy")

P = Dict{Any,Any}("Energy"=>0.1)

@show T.get_SamplingVars_(P, "Energy", sort(rand(4)), "E_width") 

@show T.get_SamplingVars_(merge(P,Dict("E_width"=>0.01)), 
													 "Energy", sort(rand(4)), "E_width")



println()

P["k"] = 0.3

Data = Dict("kLabels"=>rand(NR_ENERGIES))

@show T.get_SamplingVars(P; Data=Data, get_k=true) .|> length



println()



@show T.SamplingWeights(P) |> size

@show T.SamplingWeights(P; Data=Data, get_k=true) |> size

@show T.SampleVectors(rand(10,NR_ENERGIES), P; Data=Data, get_k=true) |> size 




#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#

println() 
@info T.Vec2Scalar
@show T.Vec2Scalar(rand(2,3))
println()
@show myPlots.Sliders.init_Vec2Scalar()(Dict())["Vec2Scalar"]


for q in myPlots.Sliders.init_Vec2Scalar()(Dict())["Vec2Scalar"]

#	@show q 
	local P = Dict("vec2scalar"=>q)

	for A in [rand(2),rand(2,4)]

#		println("\n",size(A)) 

		s1 = myPlots.Transforms.parse_vec2scalar(q)(A isa AbstractMatrix ? A[:,1] : A) 

result = T.Vec2Scalar(A,P)   

@assert isapprox(first(result), s1) 


end 
#println()
end 


#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#

println()


P = Dict("obs_i"=>1, "vec2scalar"=>"x", "Energy"=>0)


@show myPlots.Transforms.choose_obs_i(P, Dict(:a=>2,:b=>3))
@show myPlots.Transforms.choose_obs_i(P, Dict(:a=>2,:b=>3),"test1")

@show myPlots.Transforms.vec2scalar(P, rand(2), "test2")

@show myPlots.Transforms.vec2scalar(P, rand(2,3), "test3")
@show myPlots.Transforms.convol_energy(P, rand(2,3), "test3"; Data=Dict("Energy"=>[-1,0,1]))
@show myPlots.Transforms.convol_energy(P, rand(2,3); Data=Dict("Energy"=>[-1,0]), dim=1)
#

println()


myPlots.Transforms.succesive_transforms([:choose_obs_i, :convol_energy, :vec2scalar], P,
																				Dict(:a=>rand(2,3), :b=>rand(3,4)); Data=Dict("Energy"=>[-1,0,1])) .|> println
																				 
#																				 , :vec2scalar, :convol_energy 






#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#
println()



@show myPlots.Sliders.init_transforms()(Dict())

for t in first(values(myPlots.Sliders.init_transforms()(Dict())))

	occursin("Interp.+",t) || continue 

	println()
end 

showplot =false


for i in [true,false]

local x = range(0,2pi,length=rand(8:14))

#	y = hcat(sin.(x), sin.(2x), sin.(3x), sin.(4x))
#n = 1 + rand()*4

local n = rand(1:5)
#@show n 

f(x) = sin.(n*x) # + rand(length(x))*0.04# sin.(2n*x)
local y=f(x)
@time begin 

	@show size(x) size(y) 

	foreach(q->myPlots.Transforms.dominant_freq(x,y; interpolate=i),1:100)

end 
end  


acc = map(1:50) do _


x = range(0,2pi,length=rand(8:14))

#	y = hcat(sin.(x), sin.(2x), sin.(3x), sin.(4x))
#n = 1 + rand()*4

n = rand(1:5)
#@show n 

f(x) = sin.(n*x) # + rand(length(x))*0.04# sin.(2n*x)
y=f(x)


#@show size(x) size(y) ;println()


N = 100 

x0 = range(0,2pi,length=N);


x0l,y0l = myPlots.Transforms.interp(x,y,1;interp_N=N,dim=1) 



p = Dict("transform"=>"Interpolate", "transfparam"=>N)


(xi,yi),label = myPlots.Transforms.transform(p, (x,y); dim=1)


#fig,(ax1,ax2) = PyPlot.subplots(2) 
if showplot

ax1.plot(x0,f(x0),label="true")
ax1.scatter(x,y)
ax1.plot(x0l, y0l, label="sampled")
ax1.plot(xi, yi, label=label[1])
ax1.legend()

if sum(abs, y0l-f(x0)) < sum(abs, yi-f(x0)) 
	
println("linear is better") 

else 

	println("interp is better")

end 
println()
end 



#
#acc = map([
#			Dict("transform"=>"|Fourier|"),
#			Dict("transform"=>"Interp.+|FFT|", "transfparam"=>N)
#			]) do  p
#
#
#
#
#
#
#local	(x_i,y_i),label_i = myPlots.Transforms.transform(p, (x,y); dim=1)
#
#showplot &&	ax2.plot(x_i,
##					 y_i,
#					 Utils.Rescale(y_i,[0,1]), 
#					 label=label_i[1])
#
#
#return abs(n-x_i[1+argmax(abs.(y_i[2:end]))])
#
#
#end |> argmin 
#@show size(x) size(y) 

wo = myPlots.Transforms.dominant_freq(x,y; interpolate=false)

w = myPlots.Transforms.dominant_freq(x,y; interpolate=true)

#@show n w wo 
#println()

acc = isapprox(wo,w,atol=1e-7) ? 0 : argmin(abs.(n .- [wo, w]))

#@show acc 

showplot && ax2.legend()

return acc 

end 

println("FFT / iFFT: ",count(isequal(1), acc)/count(isequal(2), acc))





x = range(0,2pi,length=30)

y = hcat(sin.(x), sin.(2x), sin.(3x))

for (yi,dim) in zip((y,transpose(y)),(1,2))

local (x1,y1),l1 = myPlots.Transforms.transform(Dict("transform"=>"Interp.+|FFT|"),
																		 (x,yi); dim=dim)


@show size(x1) size(y1)

end 






