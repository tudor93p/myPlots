using Constants: NR_ENERGIES, ENERGIES
using myLibs.ComputeTasks: CompTask 
import myLibs: Lattices

obs_list = ["Intruder", "LocalA", "BondVector1", "SiteVectorV", "Obs1", "CaroliCurrent_5"]




@show myPlots.Sliders.pick_local(obs_list)


@show myPlots.Sliders.pick_bondvector(obs_list) 

@show myPlots.Sliders.pick_sitevector(obs_list) 

@show myPlots.Sliders.pick_nonlocal(obs_list)

@show myPlots.Sliders.pick_cc(obs_list)


@show myPlots.Sliders.init_obs(obs_list)(Dict())
@show myPlots.Sliders.init_enlim(rand(5))(Dict())

println()



@show myPlots.Sliders.init(:init_enlim, rand(5))[1](Dict())
@show myPlots.Sliders.init(:enlim, rand(5))[1](Dict())

println()

@show myPlots.Sliders.init((:init_enlim, rand(5)))[1](Dict())
@show myPlots.Sliders.init((:init_enlim, rand(5)),(:init_Vec2Scalar,))[2](Dict())


println()





P = Dict{Any,Any}("Energy"=>0.1)




println()



@show myPlots.obs_x_and_label("Obs",nothing)


@show myPlots.check_obs_type((1,2,3))
@show myPlots.check_obs_type([1,2,3])
#@show myPlots.check_obs_type(rand(2,3))
@show myPlots.check_obs_type(Dict("a"=>1,"b"=>2))
														 
														 


@show myPlots.obs_x_and_label("Obs", (0.2,0.3,-0.4))




@show myPlots.obs_x_and_label("Obs", [0.3,0.5]) 

@show myPlots.obs_x_and_label("Obs", rand(1,3,1), "", ["q","w"]) 


@show myPlots.obs_x_and_label("Obs", Dict("a"=>[1.0,2.0],"b"=>[2,5]))#, "", ["q","w"])



println()


P["interp_method"] = "Lorentzian"
P["E_width"] =0.2

@show P 

#@show 
myPlots.construct_obs0obs(P, ENERGIES, ["Obs"], [[1,2,3]], "Obs0", [30,10,20]);


println()

pt0 = myPlots.PlotTask(identity,
						identity,
						identity,
						identity,
						[identity],
						"py",
						identity
						) 

println(pt0)



for init_sli in [(:Vec2Scalar,), ((:enlim, [rand(1:2),rand(1:5)]),), ([identity],),(identity,),(),]

	for init_pl in [("s",identity), (("a",identity),)]

#		@show init_sli init_pl
		myPlots.PlotTask(pt0, init_sli..., init_pl...)

myPlots.PlotTask(identity, identity,
								 identity, identity,
								 init_sli...,
								 init_pl...,
								 )
end end 

println()  




task = myPlots.PlotTask(CompTask("no name", identity,
																				 function () end,
																				 identity,identity),
						[identity],
						myPlots.TypicalPlots.obs(identity)
						) 

#@show task 

println()


task = myPlots.PlotTask("test plot task",
									 (args...) -> Dict("abc"=>123),
									 (args...) -> [Dict("xyz"=>321)],
									 x->true,
									 x->"data",
									 [myPlots.Sliders.init_obs(["obs1","LocalObs2"]),
										myPlots.Sliders.init_enlim(ENERGIES),
										],
									 "Observables",
									 function (P) 
										

										 	out =myPlots.construct_obs0obs(Dict(),
																										 ENERGIES,
																				"Obs0",
																				ENERGIES,
																				"Obs0",
																				ENERGIES,
																				)
										 
											@show out 

											return out 
										 
										end 
									 )

#@show task 

println()

#myPlots.plot([task])
						module latt_x
																					PosAtoms(P...) = rand(2,10)
																				end



task2 = myPlots.PlotTask("test plot task local",
										(args...) -> Dict("abc"=>123),
									 (args...) -> [Dict("xyz"=>321)],
									 x->true,
									 x->(nothing,nothing),
									 myPlots.Sliders.init_localobs(["obs1","LocalObs2"]),
									 myPlots.TypicalPlots.localobs((args...;kwargs...)->(nothing,[nothing]),  latt_x
																				)...)


@show task2.get_plotparams()


#myPlots.plot([task2])




function get_latt(args...; kwargs...)


	latt = Lattices.Superlattice(Lattices.SquareLattice(), [3,2])

	Lattices.AddAtoms!(latt, rand(2,1),"X")
	Lattices.AddAtoms!(latt, rand(2,3),"Y")

	return latt

end  

q = myPlots.TypicalPlots.lattice(get_latt)




@show q[1] 

@show keys(q[2](Dict()))


@show typeof(q[2](Dict())["xys"])






#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#
println()

@info "TypicalPlots.oper"

function get_data(args...;kwargs...)


	Dict("kLabels"=>range(0,1,length=20),
			 "Energy"=>rand(20),
			 "A"=>rand(2,20),
			 "Velocity"=>rand(3,20),
			 )

end 


@show myPlots.TypicalPlots.oper(get_data)[1]
@show myPlots.TypicalPlots.oper(get_data)[2](Dict()) 

for (k,v) in myPlots.TypicalPlots.oper(get_data)[2](Dict("filterstates"=>true, "oper"=>"Velocity","obs_i"=>1,"opermin"=>0.4))

	print("$k: ")

	v isa AbstractString ? println(v) : @show length(v)
end 

println()


@show myPlots.obs_x_and_label("x", nothing, "x", nothing)

println()


D = myPlots.TypicalPlots.oper(get_data)[2](Dict("oper"=>"Velocity","obs_i"=>2))

@show D["z"] |> size 
@show D["zlabel"]



