module myPlots
#############################################################################


import PyCall 
using OrderedCollections: OrderedDict

using myLibs: Utils, Algebra, ComputeTasks

using myLibs.ComputeTasks: CompTask




export PlotTask 


@assert pkgdir(myPlots) == "/mnt/Work/scripts/julia_libraries/myPlots"

const PATH_PYPLOTS = joinpath(pkgdir(myPlots),"pyplots")
	

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

	init_sliders::Vector{Union{Function,Tuple{String,Vararg}}} 
#	init_sliders::Vector{Function}

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
									init_sliders,#::Union{Symbol,
															#				<:Tuple{Symbol, Vararg},
															#				<:Tuple{Tuple,Vararg},
															#				<:Tuple{AbstractString, Vararg},
															#				<:AbstractVector{<:Tuple},
															#				<:Function},
									pp::Union{AbstractString, 
														Tuple{<:AbstractString,<:Function}},
									args::Function...)::PlotTask

	PlotTask(name, get_plotparams, get_paramcombs, files_exist,
					 get_data, 
					 Sliders.init(init_sliders), 
					 (pp isa Tuple ? pp : (pp,))...,  args...)
	
end 


function PlotTask(name::AbstractString,
									get_plotparams::Function,
									get_paramcombs::Function,
									files_exist::Function,
									get_data::Function,
									pp::Union{<:AbstractString, 
														Tuple{<:AbstractString,<:Function}},
									args::Function...)::PlotTask

	PlotTask(name, get_plotparams, get_paramcombs, files_exist,
					 get_data, Sliders.init(), 
					 (pp isa Tuple ? pp : (pp,))...,  args...)
	
end  



function PlotTask(task::CompTask,
									args...)::PlotTask
	
	PlotTask((getproperty(task, p) for p in propertynames(task))...,
					 args...)

end 


function PlotTask(pt::PlotTask, args...)::PlotTask
									
	ks=[:name, :get_plotparams, :get_paramcombs, :files_exist, :get_data]

	return PlotTask((getproperty(pt, k) for k=ks)..., args...)

end  


#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#

function pyplot_init_sliders1!(kwargs::AbstractDict, f!::Function)::Nothing

	f!(kwargs)

	return 

end 

function pyplot_init_sliders1!(kwargs::AbstractDict, 
															 item::Tuple{<:AbstractString,Vararg}
															 )::Nothing

	pyplot_init_sliders1!(kwargs, item...)

end 


function pyplot_init_sliders1!(kwargs::AbstractDict, 
															 pyslider::AbstractString, args...
															 )::Nothing

	haskey(Sliders.pysliders_kwargs,pyslider) || return 

	kwarg = Sliders.pysliders_kwargs[pyslider] 
	
	appone, apptwo = Sliders.get_pysliders_funs(kwarg)
	
	merge!(apptwo, kwargs, Dict{String,Any}(kwarg => appone(args...)))

	return 

end 




function pyplot_init_sliders(tasks...)::Dict{String,Any}

	kwargs = Dict{String,Any}() 

	for T=tasks, item=T.init_sliders 

		pyplot_init_sliders1!(kwargs, item) 

	end 

	return kwargs

end 



function pyplot_extra_sliders(tasks...)::Vector{String}

	sliders = Set{String}() 
	
	for T=tasks, item=T.init_sliders 

		item isa Tuple && push!(sliders,item[1])

	end 

	return [sliders...]

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

#	T==2 && return obs_x_and_label(obs, val[:], suffix) 

	T==2 && return Dict(x=>val[:], l=>obs)

	T==3 && return obs_x_and_label(obs, val, suffix, sort(K))

	error()

end 




function obs_x_and_label(obs::String, val, suffix::String, labels::Utils.List)::Dict

	T,K = check_obs_type(val) 

	if T in [1,2] 

		return obs_x_and_label(join([obs;labels[1:min(end,1)]]," "),
													 ndims(val)<=1 ? val : val[:],
													 suffix)

#		return obs_x_and_label(obs, val[:], suffix, labels)

	end 


	function getv(k)
		
		isa(val, AbstractDict) && return val[k]
		
		return val.values[findfirst(isequal(k), K)]

	end


	if length(K)==1

		@assert Set(labels)==Set(K) "Label '$labels' does not exist"

		return obs_x_and_label(obs, getv(only(K)), suffix, labels)

	end 

	Ls = intersect(labels, K)

	xs,ls = ["x","label"] .* suffix .* "s"

	T==3 && return Dict(xs => reshape.(getv.(Ls),:), ls=>Ls)

end


obs_x_and_label(::String, ::Nothing, ::String, ::Nothing)::Dict = Dict()


obs_x_and_label(::String, ::Nothing, args...)::Dict = Dict()



#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#

function xlabel_curve_data(P::AbstractDict, 
													 obs0::AbstractString,
													 obs::AbstractVector, 
													 val::AbstractVector
													 )::Tuple{String,String,<:Union{AbstractVector,
																													AbstractDict,
																													Nothing}}

	errtext = "***Error_myPlots***" 

#	plotted_obs = [I[1] for (o,I) in Utils.EnumUnique(obs) if !in(o,["None", obs0])] 

#	@show findall(isnothing, val) 
#	@show plotted_obs 
	plotted_obs = Utils.mapif(!isnothing, Utils.EnumUnique(obs)) do (o,(i,))
		
		o!="None" && o!=obs0 && !isnothing(val[i]) && return i 

		return nothing 

	end  |> Vector{Int}

#	@show plotted_obs  

	isempty(plotted_obs) && return ("","",nothing)

	if get(P, "obs_group", "")=="SubObs" && length(plotted_obs)==1 

		i = only(plotted_obs)

#		@show i 

		return (obs[i], obs[i], val[i]) 

	end 

#	@show P 





	Vs,Ls = Utils.zipmap(plotted_obs) do i

#		@show i val[i] obs[i]

		Transforms.choose_obs_i(P, val[i], obs[i]; f="first") 

	end .|> collect


	if length(plotted_obs)==1 

		L = only(Ls) 

		return (L[1], length(L)>1 ? join_label(L[2:end]) : only(L), only(Vs))
		
	end 


	common_label = unique(L[end] for L in Ls)

	common_lablength = unique(length.(Ls))


	xlabel,sep_labs = if length(common_label)==1==length(common_lablength) 
		
		@assert only(common_lablength[1])==2 

		("Sub-obs: "*only(common_label), first)

	else

		("Observables", join_label)

	end 

	return (xlabel, errtext, Dict(zip(map(sep_labs,Ls),Vs)))

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
													 Energy::AbstractVector,
													 obs::AbstractVector,
													 val::AbstractVector, 
													 obs0::AbstractString, 
													 val0
													 )

	labels=labels0=nothing # obsolete


# obs => val can be "DOS" => [0.3, 4.1, 0.0, ...] 		or
#										"T" => Dict("A" => [0.3, 5.5, 0.7, ...], ...)


	out = merge!(Dict{String,Any}("xlabel0"=>obs0, 
																"y"=>Energy, "ylabel"=>"Energy"),
							 obs_x_and_label(obs0,val0, "0", labels0))

	if all(in(keys(P)), ["interp_method", "Energy", "E_width"])

		out["weights"] = Transforms.SamplingWeights(P; centers=Energy)[:]

	end
	


	axis_label, curve_label, data = xlabel_curve_data(P, obs0, obs, val) 


	out["xlabel"] = axis_label  

	#@show curve_label typeof(curve_label) data typeof(data) labels typeof(labels)


	return merge!(out, obs_x_and_label(curve_label, data, "", labels))

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

function join_label(labels::Union{AbstractString,Char}...; kwargs...)::String

	join_label(string.(vcat(labels...)); kwargs...)

end 

function join_label(labels::Union{AbstractVector{<:AbstractString},
																	Tuple{Vararg{<:AbstractString}}};
										sep1::Union{Char,AbstractString}=" / ")

	join(filter(!isempty,strip.(labels)), sep1)

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



 


#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#




function retrieve_pyplot_object(script::Union{Symbol,AbstractString}, 
																obj::Union{Symbol,AbstractString}
																)

	pushfirst!(PyCall.PyVector(PyCall.pyimport("sys")."path"), PATH_PYPLOTS)

	return getproperty(PyCall.pyimport(string(script)), Symbol(obj))

end  


function pyplot(script::AbstractString, args...; kwargs...)

	retrieve_pyplot_object(script, :plot)(args...; kwargs...)

end






plot(task::PlotTask; kwargs...) = plot([task]; kwargs...)
plot(tasks::PlotTask...; kwargs...) = plot(collect(tasks); kwargs...)


function plot(tasks::AbstractVector{PlotTask}; 
							only_prep::Bool=false, kwargs...)

	pyplot_args = Utils.invmap(tasks,	pyplot_merged_Param,
																		pyplot_pyjl_pairs,
																		pyplot_extra_sliders,
																		pyplot_init_sliders,
		)


	only_prep && return pyplot_args 

	pyplot("scheleton", pyplot_args...; kwargs...)

end 



init_plot(task::PlotTask; kwargs...) = init_plot([task]; kwargs...)
init_plot(tasks::PlotTask...; kwargs...) = init_plot(collect(tasks); kwargs...)


function init_plot(tasks::AbstractVector{PlotTask}; 
									kwargs...)

	pyjl_pairs_ = pyplot_pyjl_pairs(tasks...)

	init_slid_ = pyplot_init_sliders(tasks...)

	F = retrieve_pyplot_object("scheleton","init_plot")

	return (F(pyjl_pairs_, init_slid_; kwargs...),
					retrieve_pyplot_object("scheleton", "plot_direct_frominit"),
					)

end






#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#























































































































































































































































































































































#############################################################################
end 

