using Constants: NR_ENERGIES, ENERGIES
using myLibs.ComputeTasks: CompTask 
import myLibs: Lattices, Algebra ,Parameters

	
observables = Algebra.OuterBinary(["QP","E","H"], ["-CaroliTransm_2","-DOS"], *, flat=true)


function get_data(args...; kwargs...) 

	out = Dict{String,Any}() 


	for obs in observables 
		
		q = occursin("QP",obs) ? 1 : 0.5

		if occursin("Caroli", obs)
			

			out[obs] = Dict(

											"A-B" => abs2.(sin.(3ENERGIES))*q,
#			 "A-B" => sort(rand(NR_ENERGIES)),

#			 "B-A" => sort(rand(NR_ENERGIES),rev=true)
			 "B-A" => sort(rand(NR_ENERGIES),rev=true)*q
			 )


		elseif occursin("DOS", obs)

			out[obs] = fill(100, NR_ENERGIES)*q

		end 

	end 

	return out 

end 


param_flow = Parameters.ParamFlow("path_test_obs", 1,
																	([:x],(x=(1,0),),Dict(:x=>1)))

comp_task = Parameters.Calculation("Simulation observables", param_flow,
															get_data,
															get_data,
															function (args...) false end;
															observables=observables) |> CompTask

plot_task = myPlots.PlotTask(comp_task,
														 [(:obs, observables), (:enlim, ENERGIES)],
						myPlots.TypicalPlots.obs(get_data);
						) 

for target in ([],
							 ["QP-DOS"],
							 ["E-DOS","E-DOS"],
							 ["QP-CaroliTransm_2"],
							 ["QP-CaroliTransm_2", "E-CaroliTransm_2"],
							 ["QP-CaroliTransm_2", "E-CaroliTransm_2","H-DOS","QP-DOS"],
							 ["QP-DOS","H-DOS","E-DOS"],
							 ["E-CaroliTransm_2","E-DOS"],
							 observables,
							 )

	println("-----------")
	@show target 
	println("-----------")

	for (k,v) in plot_task.plot(Dict(
																	 "obs"=>target,
																	"obs_i"=>2,
																	"interp_method"=>"Lorentzian",
																	"Energy"=>rand()*0.35,
																	"E_width"=>0.02,
																	))

		occursin("0",k) && continue 

		(occursin("x",k)|in(k,["label","labels"]))	|| continue 


		println("\n$k: ", (isa(v,AbstractString) || eltype(v)<:AbstractString) ? v : length(v))
	
	
	end
	
	println()

end 

myPlots.plot(plot_task)

#@show task 


