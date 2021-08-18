using Constants: NR_ENERGIES, ENERGIES
using myLibs.ComputeTasks: CompTask 
import myLibs: Lattices

obs_list = ["Intruder", "LocalA", "BondVector1", "SiteVectorV", "Obs1"]




@show myPlots.pick_local(obs_list)


@show myPlots.pick_bondvector(obs_list) 

@show myPlots.pick_sitevector(obs_list) 

@show myPlots.pick_nonlocal(obs_list)


@show myPlots.init_obs(obs_list)(Dict())
@show myPlots.init_enlim(rand(5))(Dict())



println()



@show myPlots.get_SamplingVars_(Dict(), "Energy")
@show myPlots.get_SamplingVars_(Dict("Energy"=>0.1), "Energy")


P = Dict{Any,Any}("Energy"=>0.1)


@show myPlots.get_SamplingVars_(P, "Energy", sort(rand(4)), "E_width") 

@show myPlots.get_SamplingVars_(merge(P,Dict("E_width"=>0.01)), 
													 "Energy", sort(rand(4)), "E_width")



println()

P["k"] = 0.3

Data = Dict("kLabels"=>rand(NR_ENERGIES))

@show myPlots.get_SamplingVars(P; Data=Data, get_k=true)



println()



@show myPlots.SamplingWeights(P) |> size

@show myPlots.SamplingWeights(P; Data=Data, get_k=true) |> size

@show myPlots.SampleVectors(rand(10,NR_ENERGIES), P; Data=Data, get_k=true) |> size 




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
myPlots.construct_obs0obs(P, "Obs", [1,2,3], "Obs0", [30,10,20]);




println()  


myPlots.PlotTask(identity,
						identity,
						identity,
						identity,
						[identity],
						"py",
						identity
						) |> println 



task = myPlots.PlotTask(CompTask("no name", identity,
																				 function () end,
																				 identity,identity),
						[identity],
						myPlots.plot_obs(identity)
						) 

#@show task 

println()


task = myPlots.PlotTask("test plot task",
									 (args...) -> Dict("abc"=>123),
									 (args...) -> [Dict("xyz"=>321)],
									 x->true,
									 x->"data",
									 [myPlots.init_obs(["obs1","LocalObs2"]),
										myPlots.init_enlim(ENERGIES),
										],
									 "Observables",
									 function (P) 
										

										 	out =myPlots.construct_obs0obs(Dict(),
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
									 myPlots.init_localobs(["obs1","LocalObs2"]),
									 myPlots.plot_localobs((args...;kwargs...)->(nothing,[nothing]),  latt_x
																				)...)


@show task2.get_plotparams()


#myPlots.plot([task2])




function get_latt(args...; kwargs...)


	latt = Lattices.Superlattice(Lattices.SquareLattice(), [3,2])

	Lattices.AddAtoms!(latt, rand(2,1),"X")
	Lattices.AddAtoms!(latt, rand(2,3),"Y")

	return latt

end  

q = myPlots.plot_lattice(get_latt)




@show q[1] 

@show keys(q[2](Dict()))


@show typeof(q[2](Dict())["xs"])



import PyCall, PyPlot; fig,ax = PyPlot.subplots()

path = "/media/tudor/Tudor/Work/2020_Snake-states/SnakeStates/Helpers/plots/"

pushfirst!(PyCall.PyVector(PyCall.pyimport("sys")."path"), path)


PyCall.pyimport("Scatter").plot([ax], q[2],dotsize=100)



#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#


function get_data(args...;kwargs...)


	Dict("kLabels"=>range(0,1,length=20),
			 "Energy"=>rand(20),
			 )

end 


@show myPlots.plot_oper(get_data)[1]
@show myPlots.plot_oper(get_data)[2](Dict())


@show myPlots.obs_x_and_label("x", nothing, "x", nothing)






