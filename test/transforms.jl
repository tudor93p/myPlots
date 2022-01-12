T = myPlots.Transforms
import LinearAlgebra
using Constants: NR_ENERGIES
import PyPlot, Random
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
P["k_width"] = 0.1

Data = Dict("kLabels"=>rand(NR_ENERGIES))

@show T.get_SamplingVars(P; Data=Data, get_k=true) .|> length



println()



@show T.SamplingWeights(P) |> size

@show T.SamplingWeights(P; Data=Data, get_k=true) |> size

@show T.SampleVectors(rand(10,NR_ENERGIES), P; Data=Data, get_k=true) |> size 




#===========================================================================#
#
# Vector to scalar 
#
#---------------------------------------------------------------------------#

println() 

false && @testset "Vector to scalar" begin 

	@info T.Vec2Scalar 
	@test length(T.Vec2Scalar(rand(2,3)))==3

	println()
	@show myPlots.Sliders.init_Vec2Scalar()(Dict())["Vec2Scalar"]
	
	
	for q in myPlots.Sliders.init_Vec2Scalar()(Dict())["Vec2Scalar"]
	
	#	@show q 
		local P = Dict("vec2scalar"=>q)
	
		for A in [rand(2),rand(2,4)]
	
	#		println("\n",size(A)) 
	
			s1 = T.parse_vec2scalar(q)(A isa AbstractMatrix ? A[:,1] : A) 
	
		result = T.Vec2Scalar(A,P)   
		
		@test isapprox(first(result), s1) 
		
		
		end 
	#println()
	end 

end 

#===========================================================================#
#
# successive_transforms
#
#---------------------------------------------------------------------------#

println()

false && @testset  "Successive transforms" begin 

	P = Dict("obs_i"=>1, "vec2scalar"=>"y", "Energy"=>0)
	
	data = Dict(:a=>rand(2),:b=>rand(2,3))

	@test T.choose_obs_i(P, data)[1]==data[:a]
	@test T.choose_obs_i(P, data)[2]==["a"]

	@test T.choose_obs_i(P, data ,"test1")[2]==["test1","a"]
	
	@test T.vec2scalar(P, data[:a], "test2")[1]==data[:a][2] 
	
	@test T.vec2scalar(P, data[:b], "test3")[1]≈data[:b][2,:]

	ce1 = T.convol_energy(P, rand(2,3), "test3"; Data=Dict("Energy"=>[-1,0,1]))

	@test length(ce1[1])==2
	ce2 = T.convol_energy(P, rand(2,3); Data=Dict("Energy"=>[-1,0]), dim=1)

	@test length(ce2[1])==3
	
	
	println()
	
	
	T.successive_transforms([:choose_obs_i, :convol_energy, :vec2scalar], P,
																					Dict(:a=>rand(2,3), :b=>rand(3,4)); Data=Dict("Energy"=>[-1,0,1])) .|> println
																					 
	#																				 , :vec2scalar, :convol_energy 
	
end 




#===========================================================================#
#
# Interpolation 
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

	foreach(q->T.dominant_freq(x,y; interpolate=i),1:100)

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


x0l,y0l = T.interp(x,y,1;interp_N=N,dim=1) 



p = Dict("transform"=>"Interpolate", "transfparam"=>N)


(xi,yi),label = T.transform(p, (x,y); dim=1)


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




wo = T.dominant_freq(x,y; interpolate=false)

w = T.dominant_freq(x,y; interpolate=true)

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

local (x1,y1),l1 = T.transform(Dict("transform"=>"Interp.+|FFT|"),
																		 (x,yi); dim=dim)


@show size(x1) size(y1)

end 



#===========================================================================#
#
# Choose component
#
#---------------------------------------------------------------------------#




println()

false && @testset "choose component" begin 


z = rand(3)

z1,lab = T.choose_color_i(Dict("obs_i"=>1), z)

#@show size(z1) lab 
@test isapprox(z,z1)


z = rand(2,3)

z1,lab = T.choose_color_i(Dict("obs_i"=>1), z)

#@show size(z1) lab 
@test isapprox(z[1,:],z1)


z = rand(5,2,3)

z1,lab = T.choose_color_i(Dict("obs_i"=>4), z)

#@show size(z1) lab 
@test isapprox(z[4,:,:],z1)


end 





#===========================================================================#
#
# Smooth interpolation 
#
#---------------------------------------------------------------------------#



false && @testset "Smooth Interpolation" begin 

	f(x)  = sin(x) + 0.5*sin(1.3x)

	x_sparse = LinRange(0,2pi,20)

	x_dense = LinRange(0,2pi,300)

	y_noisy = f.(x_sparse) + (rand(length(x_sparse)).-0.5)*0.3

	Y_noisy = hcat(rand(length(y_noisy)),y_noisy, rand(length(y_noisy)))

	y_truth = f.(x_dense)

	y_fit0 = T.interp(x_sparse, y_noisy; interp_N=length(x_dense))[2]
	
	y_fit0_ = T.interp(x_sparse, Y_noisy; 
										 interp_N=length(x_dense), dim=1)[2][:,2]
	
	y_fit1 = T.interp(x_sparse, y_noisy; interp_N=length(x_dense),
										smooth=0.3)[2]

	y_fit1_ = T.interp(x_sparse, Y_noisy; interp_N=length(x_dense),
										 dim=1,
										smooth=0.3)[2][:,2]

	@test y_fit0 ≈ y_fit0_ 
	@test y_fit1 ≈ y_fit1_ 


	P = Dict("transform"=>"SmoothInterp.","smooth"=>0.3,
					 "transfparam"=>length(x_dense)) 


	@test y_fit1 ≈ T.pd_smoothinterp(P, (x_sparse, y_noisy))[1][2]


	@test y_fit1 ≈ T.transform(P, (x_sparse, y_noisy))[1][2]


	PyPlot.scatter(x_sparse,y_noisy;label="data")

	PyPlot.plot(x_dense,y_truth; label="truth")
	
	PyPlot.plot(x_dense,y_fit0; label="s=0")
	PyPlot.plot(x_dense,y_fit1; label="s=0.3") 

	PyPlot.legend()


end 






@testset "Smooth Interpolation + Fourier" begin 

	f(x)  = sin(x) + 0.5*sin(1.3x)

	x_sparse = LinRange(0,2pi,20)

	x_dense = LinRange(0,2pi,300)

	y_noisy = f.(x_sparse) + (rand(length(x_sparse)).-0.5)*0.3

	Y_noisy = hcat(rand(length(y_noisy)),y_noisy, rand(length(y_noisy)))

	y_truth = f.(x_dense)


	P = Dict("transform"=>"SmoothInterp.+|FFT|","smooth"=>0.3,
					 "transfparam"=>length(x_dense)) 


	ky0,F1 = T.fourier_abs(x_sparse, y_noisy)

	ky1,iF1 = T.interp_and_fourier_abs(x_sparse,y_noisy; interp_N=length(x_dense))

	ky2, siF1 = T.interp_and_fourier_abs(x_sparse,y_noisy; interp_N=length(x_dense),
													 smooth=0.3)

	@test !(iF1≈siF1)

	@test ky1≈ky2 


	@test siF1 ≈ T.pd_sm_interp_fourier(P, (x_sparse, y_noisy))[1][2]
	
	@test siF1 ≈ T.transform(P, (x_sparse, y_noisy))[1][2]



	PyPlot.plot(ky0,F1;label="|FFT|")
	
	PyPlot.plot(ky1,iF1;label="i|FFT|")

	PyPlot.plot(ky2,siF1;label="si|FFT|")


	PyPlot.legend()


end 
