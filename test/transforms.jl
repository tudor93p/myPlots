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





