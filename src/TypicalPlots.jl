module TypicalPlots
#############################################################################

using myLibs.ComputeTasks: CompTask
import myLibs: Lattices ,Utils

using ..myPlots: PlotTask, construct_obs0obs
using Constants: VECTOR_STORE_DIM 

import ..Transforms 

#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#



obs(task::CompTask) = obs(task.get_data) 

obs(get_data::Function) = ("Observables", function plot_(P::AbstractDict)
																	
	obs0 = "QP-DOS"

	obs_ = get(P, "obs", obs0)

	Data = get_data(P, mute=false, fromPlot=true, target=[obs_,obs0])

	return construct_obs0obs(P, obs_,	get(Data, obs_, 	nothing),
													 		obs0, get(Data, obs0, nothing)
													 )
end)


#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#


localobs(task::Union{CompTask,PlotTask}, arg...) = localobs(task.get_data, arg...) 


localobs(get_data::Function, PosAtoms::Function) = ("LocalObservables", function plot_(P::AbstractDict)
	
	localobs_ = get(P, "localobs", "QP-LocalDOS")::AbstractString
	
	Data, good_P = get_data(P, mute=false, fromPlot=true, target=localobs_,
													get_good_P=true)
	
	atoms = PosAtoms(good_P...)

	(isnothing(Data) || !haskey(Data,localobs_)) && return Dict("xy"=>atoms)

	@assert haskey(P, "Energy")

	return Dict("xy" => atoms, 
							"z" => Transforms.SampleVectors(Data[localobs_], P; Data=Data, get_k=true))
	
end)


localobs(get_data::Function, lattice::Module) = localobs(get_data, lattice.PosAtoms)





#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#

oper(task::Union{CompTask,PlotTask}) = oper(task.get_data)

oper(get_data::Function) = ("Hamilt_Diagonaliz", function (P::AbstractDict)

	oper_ = get(P, "oper", nothing)

	Data = get_data(P, mute=false, fromPlot=true, target=oper_)


  out = Dict(

		"xlabel" => haskey(Data, "kTicks") ? "k" : "Eigenvalue index",

		"ylabel" => "Energy",

		"zlabel" => oper_,


		"x" => Data["kLabels"][:],

#		"xticks" => Data["kTicks"],

		"y" => Data["Energy"][:],

		"z" => haskey(Data, oper_) ? Data[oper_][:] : nothing,

					)

	if oper_=="weights" && all(in(keys(P)), ["interp_method","Energy","E_width"])

		out["z"] = Transforms.SamplingWeights(P; Data=Data, get_k=true)

	end

	return out

end)




#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#




lattice(task::CompTask) = lattice(task.get_data)


lattice(get_data::Function) = ("Scatter", function plot_(P::AbstractDict) 

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
