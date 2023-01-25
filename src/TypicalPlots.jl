module TypicalPlots
#############################################################################

using myLibs.ComputeTasks: CompTask
import myLibs: Lattices, Utils

using ..myPlots: PlotTask, construct_obs0obs, join_label
using Constants: VECTOR_STORE_DIM 

import ..Transforms, ..Sliders 

#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#



obs(task::Union{CompTask,PlotTask}, args...) = obs(task.get_data, args...) 

function obs(get_data::Function)::Tuple{String,Function}
	
	function plot_(P::AbstractDict)
																	
		obs0 = "QP-DOS"
	
		obs_ = vcat(get(P, "obs", obs0))
	
		Data = get_data(P, mute=false, fromPlot=true, target=vcat(obs_,obs0))
	
		return construct_obs0obs(P, obs_,	[get(Data, o_, 	nothing) for o_ in obs_],
														 		obs0, get(Data, obs0, nothing) 
														 )
	
	end 

	
	return "Observables", plot_ 

end 


function obs(get_data::Function,
						 observables::AbstractVector,
						 filter_same_::Function
						 )::Tuple{String,Function} 

	pyscript, plot_ = obs(get_data)

	add_group_obs_ = Sliders.add_group_obs(observables, filter_same_)

	return (pyscript, plot_∘add_group_obs_)

end 



#===========================================================================#
#
# Local observable or operator
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


localobs(get_data::Function, PosAtoms::Function) = ("LocalObservables", function plot_(P::AbstractDict)::Dict
	
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

	function plot_(P::AbstractDict)::Dict

		oper_ = get(P, "oper", nothing)


		Data = get_data(P, mute=false, fromPlot=true, target=oper_)
	
	
		out = Dict{String,Any}(
							 
			"xlabel" => get(Data, "kLabel",
											ifelse(haskey(Data,"kTicks"),
														 "Momentum",
														 "Eigenvalue index")),
	
			"ylabel" => "Energy",
	
			"x" => Data["kLabels"][:],
	
			"y" => Data["Energy"][:],

			"xlim" => extrema(Data["kLabels"]),
	
			)



		if haskey(Data, "kTicks")
			
			out["xticks"] = Data["kTicks"] 
			
			if haskey(Data, "kTicklabels") 

				out["xticklabels"] = Data["kTicklabels"]

			end 

		end 






		if haskey(Data, oper_) 

			z,lab1 = Transforms.choose_color_i(P, Data[oper_], oper_; f="first") 

			@assert ndims(z)==1 && length(z)==length(out["y"])==length(out["x"])


			xyz,lab2 = Transforms.filter_states(P, (z, out["x"], out["y"], z))

			@assert length(xyz)==3 


			for (k,v) in zip("xyz",xyz)

				out[string(k)] = v 

			end 

			if oper_=="Velocity" 
				
				@assert length(lab1)==2

				lab1[2] = string(only(lab1[2]) + ('x'-'1'))

			end  

			out["zlabel"] = join_label(join_label(lab1,sep1="_"), lab2..., sep1=" ")


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
