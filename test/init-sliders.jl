using myLibs.ComputeTasks: CompTask 

energies = Vector(LinRange(-0.5,0.5,100))


obs_list = ["Intruder", "LocalA", "BondVector1", "SiteVectorV", "Obs1", "CaroliCurrent_5"]

myPlots.Sliders.init_obs(obs_list)(Dict())
myPlots.Sliders.init_enlim(rand(5))(Dict())

#println()



myPlots.Sliders.init(:init_enlim, rand(5))[1](Dict())
myPlots.Sliders.init(:enlim, rand(5))[1](Dict())

#println()

myPlots.Sliders.init((:init_enlim, rand(5)))[1](Dict())
myPlots.Sliders.init((:init_enlim, rand(5)),(:init_Vec2Scalar,))[2](Dict())


#println()


pt0 = myPlots.PlotTask(identity,
						identity,
						identity,
						identity,
						[identity],
						"py",
						identity
						) 

#println(pt0)


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

#println()  




task = myPlots.PlotTask(CompTask("no name", identity,
																				 function () end,
																				 identity,identity),
						[identity],
						myPlots.TypicalPlots.obs(identity)
						) 

#@show task 

#println()


task = myPlots.PlotTask("test plot task",
									 (args...) -> Dict("abc"=>123),
									 (args...) -> [Dict("xyz"=>321)],
									 x->true,
									 x->"data",
									 [myPlots.Sliders.init_obs(["obs1","LocalObs2"]),
										myPlots.Sliders.init_enlim(energies),
										],
									 "Observables",
									 function (P) 
										

										 	out =myPlots.construct_obs0obs(Dict(),
																										 energies,
																				"Obs0",
																				energies,
																				"Obs0",
																				energies,
																				)
										 
#											@show out 

											return out 
										 
										end 
									 )

#@show task 

#println()

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


task2.get_plotparams()


#myPlots.plot([task2])

# ---------------------------- new methods ------------------ #
#



#println()  

a_b_s = [rand(),1,[1,2,3],[3,2],rand(2),rand(2,3,5),[[1 2]; [3 4]],
			 (1,2,3),(1,),(9.3,4),(2.3,6.2)]

for a in a_b_s, b in a_b_s 

	for item in myPlots.Sliders.py_enlim(a,b)
@assert 	min(minimum(a),minimum(b)) <=  item <= max(maximum(a),maximum(b))

end 

end 

println()

@assert length(myPlots.Sliders.py_opers(["a","b"]))==4

@assert myPlots.Sliders.py_vec2scalar() == ["x", "x/norm", "x^2", "y", "y/norm", "y^2", "Angle", "Norm"]


@assert myPlots.Sliders.py_transf("a","b")==["None","a","b"]





println()
									
sli_ini3 = [ 
						("observables", ["A","B","C"]), ("obs_index", 8), 
						(:obs,["D","B"]),(:enlim,rand(10)),
						]


for si3 in [sli_ini3..., sli_ini3]

	println()
	@show si3 
	@show typeof(si3)

	@show myPlots.Sliders.init(si3)

	println()



task3 = myPlots.PlotTask("test sliders 3",
										(args...;kwargs...) -> Dict("abc"=>123),
									 (args...;kwargs...) -> [Dict("xyz"=>321)],
									 (args...;kwargs...)->true,
									 (args...;kwargs...)->(nothing,nothing),
									 si3,
									 "Curves_yofx",
									 (args...;kwargs...)-> Dict("x"=>[1,2],"y"=>[4,3])
									 )


@show task3.init_sliders 

println()

println(myPlots.pyplot_init_sliders(task3))
println(myPlots.pyplot_init_sliders(task3,task3))
println(myPlots.pyplot_init_sliders(task,task3,task2,pt0))


println()

println(myPlots.pyplot_extra_sliders(task3))
println(myPlots.pyplot_extra_sliders(task3,task3))
println(myPlots.pyplot_extra_sliders(task,task3,task2,pt0)) 


#myPlots.plot(task,task3,task2)#,only_prep=true)



end 





































