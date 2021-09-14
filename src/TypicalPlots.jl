module TypicalPlots
#############################################################################

using myLibs.ComputeTasks: CompTask
import myLibs: Lattices ,Utils

using ..myPlots: PlotTask, construct_obs0obs, join_label
using Constants: VECTOR_STORE_DIM 

import ..Transforms 

#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#



obs(task::Union{CompTask,PlotTask}) = obs(task.get_data) 

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


localobs(task::Union{CompTask,PlotTask}, arg...; kwargs...) = localobs(task.get_data, arg...; kwargs...) 
#
#
#localobs(get_data::Function, Latt::Function; nr_uc:Int=0) = ("LocalObservables", function plot_(P::AbstractDict)
#	
#	localobs_ = get(P, "localobs", "QP-LocalDOS")::AbstractString
#	
#	Data, good_P = get_data(P, mute=false, fromPlot=true, target=localobs_,
#													get_good_P=true)
#	
#	latt = Latt(good_P...)
#
#
#
#	(isnothing(Data) || !haskey(Data,localobs_)) && return Dict("xy"=>atoms)
#
#	@assert haskey(P, "Energy")
#
#	return Dict("xy" => atoms, 
#							"z" => Transforms.SampleVectors(Data[localobs_], P; Data=Data, get_k=true))
#	
#end)
#
#
#localobs(get_data::Function, lattice_::Module; kwargs...) = localobs(get_data, lattice_.Latt; kwargs...)


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


localobs(get_data::Function, lattice_::Module) = localobs(get_data, lattice_.PosAtoms)



#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#

oper(task::Union{CompTask,PlotTask}) = oper(task.get_data)

oper(get_data::Function) = ("Hamilt_Diagonaliz", 

	function plot_(P::AbstractDict)

		oper_ = get(P, "oper", nothing)
	
		Data = get_data(P, mute=false, fromPlot=true, target=oper_)
	
	
	  out = Dict(
	
			"xlabel" => haskey(Data, "kTicks") ? "k" : "Eigenvalue index",
	
			"ylabel" => "Energy",
	
			"x" => Data["kLabels"][:],
	
	#		"xticks" => Data["kTicks"],
	
			"y" => Data["Energy"][:],
	
			)
	
		if haskey(Data, oper_) 

			@show oper size(Data[oper_]) P 

			z,lab = Transforms.choose_color_i(P, Data[oper_], oper_; f="first") 

			@show size(z) lab  length(out["y"])

			@assert z isa AbstractVector && length(z)==length(out["y"])

			@assert !isempty(lab)

			out["z"] = collect(z)

			if length(lab)==2 && oper_=="Velocity" 

				out["zlabel"] = join_label(lab[1], only(lab[2])+('x'-'1'), sep1=" ")

			else 

				out["zlabel"] = join_label(lab)

			end  

		elseif oper_=="weights" && haskey(P, "Energy")
	
			out["z"] = Transforms.SamplingWeights(P; Data=Data, get_k=true)

			out["zlabel"] = oper_ 

		end
	
		return out
	
	end)




#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#



lattice(task::Union{CompTask,PlotTask}; kwargs...) = lattice(task.get_data; kwargs...)

function lattice(get_data::Function; nr_uc::Int=0, kwargs...) 

	expand(n::Int)::Vector{Int} = [n,-n]

	function plot_(P::AbstractDict)::Dict{String,Any}

		latt = get_data(P, mute=false, fromPlot=true) 

		d = Lattices.LattDim(latt)

		ns = if d==0

						[0]
				
				else 

#					vcat(Utils.DistributeBallsToBoxes.(0:nr_uc, d, expand)...)

					eachcol(Utils.vectors_of_integers(d, nr_uc; dim=2))
				end 
				
		iter = Base.product(Lattices.sublatt_labels(latt), ns) 

		function lxy((label, Ns))::Tuple{String, Matrix{Float64}}

			text = string(label)
			
			if length(ns)>1 
				
				text *= ", UC="
				
				text *= string((length(Ns)==1 ? Ns : ["(",join(Ns,','),")"])...)

			end  

			length(Ns)==1 ? Ns[1] : "("*join(Ns,",")*")"

			atoms = Lattices.Atoms_ManyUCs(latt; label=label, Ns=Ns) 

			return (text, Lattices.VecsOnDim(atoms; dim=2))

		end 

		return Dict(zip(["labels", "xys"], Utils.zipmap(lxy, iter)))
	
	end 


	return ("ColoredAtoms", plot_)

end 






















































































































































































































































































































































































































































































































#############################################################################
end 
