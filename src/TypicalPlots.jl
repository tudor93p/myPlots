module TypicalPlots
#############################################################################

using myLibs.ComputeTasks: CompTask
import myLibs: Lattices ,Utils

using ..myPlots: PlotTask 
using Constants: VECTOR_STORE_DIM 

#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#



plot_obs(task::CompTask) = plot_obs(task.get_data) 

plot_obs(get_data::Function) = ("Observables", function plot_(P::AbstractDict)
																	
	obs0 = "QP-DOS"

	obs = get(P, "obs", obs0)

	Data = get_data(P, mute=false, fromPlot=true, target=[obs,obs0])

	return construct_obs0obs(P, obs,	get(Data, obs, 	nothing),
													 		obs0, get(Data, obs0, nothing)
													 )
end)


#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#


plot_localobs(task::Union{CompTask,PlotTask}, arg...) = plot_localobs(task.get_data, arg...) 


plot_localobs(get_data::Function, PosAtoms::Function) = ("LocalObservables", function plot_(P::AbstractDict)
	
	localobs = get(P, "localobs", "QP-LocalDOS")::AbstractString
	
	Data, good_P = get_data(P, mute=false, fromPlot=true, target=localobs,
													get_good_P=true)
	
	atoms = PosAtoms(good_P...)

	(isnothing(Data) || !haskey(Data,localobs)) && return Dict("xy"=>atoms)
	
	return Dict("xy" => atoms, 
							"z" => SampleVectors(Data[localobs], P; Data=Data, get_k=true))
	
end)


plot_localobs(get_data::Function, lattice::Module) = plot_localobs(get_data, lattice.PosAtoms)





#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#

plot_oper(task::Union{CompTask,PlotTask}) = plot_oper(task.get_data)

plot_oper(get_data::Function) = ("Hamilt_Diagonaliz", function (P::AbstractDict)

	oper = get(P, "oper", nothing)

	Data = get_data(P, mute=false, fromPlot=true, target=oper)


  out = Dict(

		"xlabel" => haskey(Data, "kTicks") ? "k" : "Eigenvalue index",

		"ylabel" => "Energy",

		"zlabel" => oper,


		"x" => Data["kLabels"][:],

#		"xticks" => Data["kTicks"],

		"y" => Data["Energy"][:],

		"z" => haskey(Data, oper) ? Data[oper][:] : nothing,

					)

	if oper=="weights" && all(in(keys(P)), ["interp_method","Energy","E_width"])

		out["z"] = SamplingWeights(P; Data=Data, get_k=true)

	end

	return out

end)




#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#




plot_lattice(task::CompTask) = plot_lattice(task.get_data)


plot_lattice(get_data::Function) = ("Scatter", function plot_(P::AbstractDict) 

		latt = get_data(P, mute=false, fromPlot=true) 

		labels = Lattices.sublatt_labels(latt) 

		sel = collect ∘ Utils.sel([2,1][VECTOR_STORE_DIM]) 


		function lxy(label)::Tuple{String, Vector{Float64}, Vector{Float64}}
			
			atoms = Lattices.PosAtoms(latt; label=label)

			return (string(label), sel(atoms, 1), sel(atoms, 2))

		end 


		return Dict(zip(["labels", "xs","ys"], Utils.zipmap(lxy, labels)))
	
	end)
























































































































































































































































































































































































































































































































#############################################################################
end 
