T = myPlots.Transforms
using Constants: NR_ENERGIES





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

	occursin("comp",t) || continue 

	println()

	@info t 

	p = Dict("transform"=>t,"transfparam"=>1)

	x = range(0,2pi,length=100) 

#	y = hcat(sin.(x), sin.(2x), sin.(3x), sin.(4x))

	y=sin.(x)

	(x1,y1),label = myPlots.Transforms.transform(p, (x,y); dim=1)

	@show size(x1)

	@show size(y1) 

	@show sum(abs, imag(y1)) 
	@show label 

#	@show  x1[argmax.(eachcol(y1))]


	


end 
















