module myPlots
#############################################################################


import PyCall 
using OrderedCollections: OrderedDict

using myLibs: Utils, Algebra, ComputeTasks

using myLibs.ComputeTasks: CompTask


using Constants: ENERGIES, HOPP_CUTOFF, VECTOR_STORE_DIM, MAIN_DIM, SECOND_DIM, PATH_SNAKE

export PlotTask 




#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#




#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#



struct PlotTask 

	name::String

	get_plotparams::Function 
	
	get_paramcombs::Function 
	
	files_exist::Function 
	
	get_data::Function 

	init_sliders::Vector{Function}

	pyplot_script::String 

	plot::Function 

end  





#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#


include("Sliders.jl")




#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#


function PlotTask(get_plotparams::Function, args...)

	PlotTask("", get_plotparams, args...)

end 

function PlotTask(name::AbstractString,
									get_plotparams::Function,
									get_paramcombs::Function,
									files_exist::Function,
									get_data::Function,
									init_sliders::Union{Symbol,
																			Tuple{Symbol, Vararg},
																			Tuple{Tuple,Vararg},
																			AbstractVector,
																			Function},
									args...)::PlotTask

	PlotTask(name, get_plotparams, get_paramcombs, files_exist,
					 get_data, Sliders.init(init_sliders), args...)
	
end 


function PlotTask(name::AbstractString,
									get_plotparams::Function,
									get_paramcombs::Function,
									files_exist::Function,
									get_data::Function,
									pp::Union{AbstractString, 
														Tuple{<:AbstractString,<:Function}},
									args...)::PlotTask

	PlotTask(name, get_plotparams, get_paramcombs, files_exist,
					 get_data, Sliders.init(), pp, args...)
	
end  

function PlotTask(name::AbstractString,
									get_plotparams::Function,
									get_paramcombs::Function,
									files_exist::Function,
									get_data::Function,
									init_sliders::AbstractVector{Function},
									pp::Tuple{<:AbstractString,<:Function}
									)::PlotTask

	PlotTask(name, get_plotparams, get_paramcombs, files_exist,
					 get_data, init_sliders, pp...)
	
end 






function PlotTask(task::CompTask,
									args...)::PlotTask
	
	PlotTask((getproperty(task, p) for p in propertynames(task))...,
					 args...)

end 
#
#									init_sliders::AbstractVector{<:Function},
#									pyplot_script::AbstractString,
#									plot_::Function)::PlotTask
#
#					 init_sliders, pyplot_script, plot_)
#
#end 
#
#function PlotTask(task::CompTask,
#									init_sliders::AbstractVector{<:Function},
#									pp::Tuple{<:AbstractString,<:Function})::PlotTask
#
#	PlotTask(task, init_sliders, pp...)
#
#end 
#
#
#function PlotTask(task::CompTask,
#									init_sliders::Union{Symbol,
#																			Tuple{Symbol, Vararg},
#																			Tuple{Tuple,Vararg},
#																			AbstractVector,
#																			Function},
#									args...
#									)::PlotTask
#
#	PlotTask(task, Sliders.init(init_sliders), args...)
#
#end 
#
#
#function PlotTask(task::CompTask,
#									pp::Union{AbstractString, 
#														Tuple{<:AbstractString,<:Function}},
#									args...)
#
#
#	PlotTask(task, Sliders.init(), pp, args...)
#
#end 
#
#

function PlotTask(pt::PlotTask, args...)::PlotTask
									
	ks=[:name, :get_plotparams, :get_paramcombs, :files_exist, :get_data]

	return PlotTask((getproperty(pt, k) for k in ks)..., args...)

end  


#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#




include("Transforms.jl")

#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#


	

function check_obs_type(val)

	Utils.isList(val, Real) && return 1,[]
	
	isa(val, AbstractArray) && count(!isequal(1), size(val))<=1 && return 2,[]


	if !isa(val,AbstractDict) #Utils.is_dict_or_JLDAW(val)
		
		isa(val, AbstractArray) && @show size(val)

		error(typeof(val)," not supported")

	end

	K = isa(val, AbstractDict) ? keys(val) : val.keys

	return 3, collect(K)

end 



function obs_x_and_label(obs::String, val, suffix::String="", labels::Nothing=nothing)::Dict

	x,l = ["x","label"] .* suffix

	T,K = check_obs_type(val) 

	T==1 && return Dict(x => vcat(val...), l => obs)

	T==2 && return obs_x_and_label(obs, val[:], suffix)

	T==3 && return obs_x_and_label(obs, val, suffix, sort(K))

	error()

end 




function obs_x_and_label(obs::String, val, suffix::String, labels::Utils.List)::Dict

	T,K = check_obs_type(val) 

	T==1 && return obs_x_and_label("$obs "*first(labels), val, suffix)

	T==2 && return obs_x_and_label(obs, val[:], suffix, labels)


	function getv(k)
		
		isa(val, AbstractDict) && return val[k]
		
		return val.values[findfirst(isequal(k), K)]

	end


	if length(K)==1

		Set(labels)==Set(K) || error("Label '$labels' does not exist")

		return obs_x_and_label(obs, getv(only(K)), suffix, labels)

	end 

	Ls = intersect(labels, K)

	xs,ls = ["x","label"] .* suffix .* "s"

	T==3 && return Dict(xs => reshape.(getv.(Ls),:), ls=>Ls)

end


obs_x_and_label(::String, ::Nothing, ::String, ::Nothing)::Dict = Dict()


function obs_x_and_label(::String, ::Nothing, args...)::Dict

	Dict()

end 

#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#

#get_val_co0o(P::AbstractDict)::Function = function get_val(obs_, val_)
#
#		V,lab_ = Transforms.choose_obs_i(P, val_; f="first") 
#
#		return (isempty(lab_) ? obs_ : only(lab_), V)
#
#	end 

function construct_obs0obs(P::AbstractDict, 
													 obs::AbstractVector,
													 val::AbstractVector, 
													 obs0::AbstractString, val0, 
													 labels=nothing, labels0=labels)


# obs => val can be "DOS" => [0.3, 4.1, 0.0, ...] 		or
#										"T" => Dict("A" => [0.3, 5.5, 0.7, ...], ...)


	out = Dict("xlabel0" => obs0, "y" => ENERGIES, "ylabel" => "Energy")



	plotted_obs = [I[1] for (o,I) in Utils.EnumUnique(obs) if !in(o,["None", obs0])]



	if !isempty(plotted_obs)

		#out["xlabel"] = obs 

		Vs,Ls = Utils.zipmap(plotted_obs) do i

			Transforms.choose_obs_i(P, val[i], obs[i]; f="first") 

		end .|> collect


		axis_label, curve_label, data = if length(plotted_obs)==1 

			L = only(Ls) 
		
			(L[1], length(L)>1 ? join_label(L[2:end]) : only(L), only(Vs))
			

		else 

			common_label = unique(L[end] for L in Ls)

			common_lablength = unique(length.(Ls))


			xlabel,sep_labs = if length(common_label)==1==length(common_lablength) 
				
				@assert only(common_lablength[1])==2 

				("Sub-obs: "*only(common_label), map(first,Ls))

			else

				("Observables", map(join_label, Ls))

			end 


			(xlabel, "***Error_myPlots***", Dict(zip(sep_labs,Vs)))

		end 


#
#
##		axis_label,curve_labels = 
#		
#
#		axis_label, X, data = if length(common_label)==length(unique(length.(Ls)))==1
#			
#			xlabel = only(common_label)
#
#
#			if all(isempty, separate_labels)
#
#				@assert length(separate_labels)==1 
#
#				(xlabel, xlabel, only(Vs))
#
#			elseif all(!isempty, separate_labels)
#
#				(xlabel, "", Dict(zip(separate_labels,Vs)))
#
#			end 
#
#		else 
#	
#			("Observables", 
#			 "74334", 
#			 Dict(join_label(L)=>V for (V,L) in zip(Vs,Ls)))
#
#		end 

		merge!(out, obs_x_and_label(curve_label, data, "", labels))

		out["xlabel"] = axis_label 



#			out["xlabel"] = "Observables"
#
#			obs_x_and_label("", 
#
#			Dict(join_label(L)=>V for (V,L) in zip(Vs,Ls)), "", labels) 
#
#
#			, map(join_label, Ls))
#
#		merge!(out, obs_x_and_label("",
#																Dict(zip(curve_labels,Vs)), "", labels))



#		merge!(out, obs_x_and_label(get_val(obs, val)..., "", labels))

	end



	if all(in(keys(P)), ["interp_method", "Energy", "E_width"] )

		out["weights"] = Transforms.SamplingWeights(P)[:]

	end
	
	return merge(out, obs_x_and_label(obs0,val0, "0", labels0))

end




#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#




#===========================================================================#
#
# Split long labels in two rows
#
#---------------------------------------------------------------------------#

function join_label(labels::Vararg{<:Union{AbstractString,Char}}; kwargs...)::String

	join_label(string.(vcat(labels...)); kwargs...)

end 

function join_label(labels::AbstractVector{<:AbstractString};
										sep1::Union{Char,AbstractString}="/")
	
	join(labels, sep1)

end 


function split_label(labels::AbstractVector{<:AbstractString};
										 sep2::Union{Char,AbstractString}="\n",
										 kwargs...
										 )::String

	isempty(labels) && return ""

	length(labels)==1 && return only(labels)

	possib = map(1:length(labels)-1) do i

		map([<=(i), >(i)]) do f 

			join_label(labels[f.(axes(labels,1))]; kwargs...)
						
		end 

	end 


	return join(possib[argmin([abs(-(length.(p)...)) for p in possib])], sep2)

end 


#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#




include("TypicalPlots.jl")


#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#


function pyplot_pyjl_pairs(tasks...)

	map(tasks) do t 

		[t.pyplot_script, t.plot, ComputeTasks.get_taskname(t)]

	end

end
  
function pyplot_merged_Param(tasks...)

	@assert !isempty(tasks)

	out = merge((task.get_plotparams() for task in tasks)...)

	K = collect(keys(out))

	prep(x) = isa(x, AbstractRange) ? collect(x) : x

	return K, [prep(out[k]) for k in K]

end



function pyplot_init_sliders(tasks...)

	fig_init = Dict()

  for T in tasks

#		!isdefined(T, :init_sliders) && continue

		Utils.invmap((fig_init,), T.init_sliders)

  end

  return fig_init
	
end




function pyplot(script::AbstractString, args...; kwargs...)

	path = "$PATH_SNAKE/myPlots/pyplots/"

	pushfirst!(PyCall.PyVector(PyCall.pyimport("sys")."path"), path)

	PyCall.pyimport(script).plot(args...; kwargs...)

end






plot(task::PlotTask; kwargs...) = plot([task]; kwargs...)
plot(tasks::Vararg{PlotTask}; kwargs...) = plot(collect(tasks); kwargs...)


function plot(tasks::AbstractVector{PlotTask}; only_prep::Bool=false, kwargs...)

	pyplot_args = Utils.invmap(tasks,	pyplot_merged_Param,
																		pyplot_pyjl_pairs,
																		pyplot_init_sliders
		)


	only_prep && return pyplot_args 


	pyplot("scheleton", pyplot_args...; kwargs...)

end 








#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#


function main_secondary_dimensions()::Tuple{String,String}

	Tuple(["x","y"][[MAIN_DIM, SECOND_DIM]])

end 




#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#























































































































































































































































































































































#############################################################################
end 

