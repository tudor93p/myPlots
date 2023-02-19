module Sliders
#############################################################################

import myLibs: Utils 

using Constants:SYST_DIM

#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#


pick_local(obs_list) = filter(o->occursin("Local",o), obs_list)

pick_bondvector(obs_list) = filter(o->occursin("BondVector",o),obs_list)

pick_sitevector(obs_list) = filter(o->occursin("SiteVector",o),obs_list)

pick_cc(obs_list)  = filter(o->occursin("CaroliCurrent",o), obs_list)


function pick_nonlocal(obs_list::AbstractVector{<:AbstractString})::Vector{String}

	rest = copy(obs_list)

	for f in [pick_local, pick_bondvector, pick_sitevector, pick_cc]

		setdiff!(rest, f(obs_list))

	end

	return rest


end


#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#

const pysliders_kwargs = Dict{String,String}(
	"energy_zoom"							=> 	"enlim",
	"choose_energy"						=>	"enlim",
	"zoom_choose_energy"			=>	"enlim",
	"operators"								=>	"HOperNames",
	"observables"							=>	"ObsNames",
	"obs_index"								=>	"max_obs_index",
	"partial_observables"			=>	"PartialObs",
	"regions"									=>	"Regions",
	"bondvector_observables"	=>	"BondVectorObsNames",
	"sitevector_observables"	=>	"SiteVectorObsNames",
	"vec2scalar"							=>	"Vec2Scalar",
	"transforms"							=>	"Transforms",
	"local_observables"				=>	"LocalObsNames",
	"pick_systems"						=>	"more_systems",
	"obs_group"								=>	"ObsGroups",
	)


const pysliders_funs = Dict{String,Tuple{Vararg{Symbol}}}(
	"enlim"								=> 	(:extrema, :py_enlim),
	"HOperNames" 					=> 	(:py_opers, ),
	"ObsNames" 						=> 	(:pick_nonlocal,),
	"LocalObsNames"				=> 	(:pick_local, ),
	"BondVectorObsNames"	=> 	(:pick_bondvector, ),
	"SiteVectorObsNames"	=>	(:pick_sitevector, ), 
	"Vec2Scalar"					=>	(:py_vec2scalar, ),
	"Regions"							=>	(:identity, :max),
	"Transforms"					=>	(:py_transf, ),
	"max_obs_index"				=>	(:identity, :max),
	"ObsGroups"						=>	(:py_obsgroups, :sortunion),

 )



#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#



function py_enlim(a::Ta, b::Tb)::NTuple{2,Float64} where {
									T<:Union{AbstractArray{<:Real},
													 Tuple{Vararg{<:Real}},
													 Real},
									Ta<:T, Tb<:T
									}

	((minimum(a)+minimum(b))/2, (maximum(a)+maximum(b))/2)

end  


sortunion = sort∘union 

function py_opers(oper::AbstractVector)::Vector{String}

	sort(unique(["-"; pick_nonlocal(oper); "weights"]))

end 

function py_obsgroups(gr::AbstractVector)::Vector{String}

	unique(vcat("-", gr))

end 

function py_vec2scalar()::Vector{String}

	map(string, [([i, i*"/norm", i*"^2"] for i='x'.+(0:SYST_DIM-1))...;
							 "Angle"; "Norm"; ])

end 

function py_transf(t::AbstractString...)::Vector{String} 

	isempty(t) || return vcat("None",t...) 

	return ["None", "Interpolate", "SmoothInterp.", "|FFT|", "Interp.+|FFT|", "SmoothInterp.+|FFT|", "FourierComp."]

end  


function get_pysliders_funs(kwarg::AbstractString
														)::Tuple{Function,Function}

	get_pysliders_funs(pysliders_funs[kwarg]...)

end  

function get_pysliders_funs(appone::Symbol,
														apptwo::Union{Symbol,Function}=union 
														)::Tuple{Function,Function}

	(retrieve_function(appone), retrieve_function(apptwo))

end 



#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#

#end 


retrieve_function(f::Function)::Function = f

function retrieve_function(f::Symbol,
													 prefix::Union{Char,AbstractString,Symbol}=""
													 )::Function  


	for M=(@__MODULE__, Base), f_=(f,Symbol(string(prefix,f)))
	
		isdefined(M,f_) && return getproperty(M, f_)

	end 

	error("Function '$f' not found in Sliders or Base")
	
end  


function add_group_obs(observables::AbstractVector, 
												filter_same_::Function, # temp. compromise 
												kind::Symbol=:nonlocal)::Function

	kinds = [:nonlocal, :local, :bondvector, :sitevector, :cc]

	if !in(kind,kinds)

		@warn "The type of observable '$kind' does not exist. Please use one of $kinds. No grouping is possible."

		return identity

	end 

	obs_group = unique(retrieve_function(kind, "pick_")(observables))

	length(obs_group)==1  && return identity 


	return function all_compat_obs(P::AbstractDict)::AbstractDict
	
		get(P,"obs_group","-") in ["Prefix","Name"] || return P  

		out = filter_same_(P["obs_group"])(P["obs"], obs_group)

#		F = Helpers.ObservableNames.filter_same_(P["obs_group"])
	
		return Set(out)==Set([P["obs"]]) ? P : Utils.adapt_merge(P, "obs"=>out) 

	end 

end 



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





init_obs(obs) = function io(d)

		merge!(union, d, Dict("ObsNames" => pick_nonlocal(obs)))

	end


init_localobs(obs) = function ilo(d) 

		merge!(union, d, Dict("LocalObsNames"=>	pick_local(obs)))

	end


init_bondvectorobs(obs) = function ibvo(d)

		merge!(union, d, Dict("BondVectorObsNames" => pick_bondvector(obs)))

	end

init_sitevectorobs(obs) = function isvo(d)

		merge!(union, d, Dict("SiteVectorObsNames" => pick_sitevector(obs)))

	end


#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#


init_enlim(ys) = function (d)
	
		merge!(d, Dict("enlim"=> extrema(ys))) do a,b

			((minimum(a)+minimum(b))/2,(maximum(a)+maximum(b))/2)

		end 

	end


#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#


init_oper(oper) = function iop!(d)

		merge!(union, d, Dict("HOperNames"=>["-";pick_nonlocal(oper);"weights"]))

	end




#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#


init_Vec2Scalar() = function ivs!(d::AbstractDict)

	xyz = ([i, i*"/norm", i*"^2"] for i in 'x'.+(0:SYST_DIM-1))

	return merge!(union, d, Dict("Vec2Scalar" => map(string, [	
							 xyz... ;  "Angle"; "Norm";
			 
			])))

	end 





#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#


init_regions(n::Int) = function addregions!(d::AbstractDict)

	merge!(max, d, Dict("Regions"=>n))

end




#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#



init_transforms(t::Vararg{<:AbstractString}) = function addtransf!(d)

	merge!(union, d, Dict("Transforms"=> vcat("None",t...)))

end 

init_transforms() = init_transforms("Interpolate",
																		"SmoothInterp.",
																		"|FFT|", 
																		"Interp.+|FFT|",
																		"SmoothInterp.+|FFT|",
																		"FourierComp.",
																		)


#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#




function init(f::Symbol, args...
						 )::Vector{Union{Function,Tuple{String,Vararg}}} 

	F::Function = retrieve_function(f,"init_")
	
	return Union{Function,Tuple{String,Vararg}}[F(args...)]


end 

function init(t::Tuple)::Vector{Union{Function,Tuple{String,Vararg}}}

	init(t...)

end 

function init(tuples::Tuple...
						 )::Vector{Union{Function,Tuple{String,Vararg}}}
	
	out = Vector{Union{Function,Tuple{String,Vararg}}}(undef, length(tuples))

	for (i,t) in enumerate(tuples)

		setindex!(out, init(t...), i:i)

	end 

	return out 

end 

function init(tuples::AbstractVector{<:Tuple}
						 )::Vector{Union{Function,Tuple{String,Vararg}}} 


	out = Vector{Union{Function,Tuple{String,Vararg}}}(undef, length(tuples))

	for (i,t) in enumerate(tuples)

		setindex!(out, init(t...), i:i)

	end 

	return out 

end  


function init(pyslider::AbstractString, args...
						 )::Vector{Union{Function,Tuple{String,Vararg}}} 

	Union{Function,Tuple{String,Vararg}}[(string(pyslider), args...)]

end 


function init(fs::AbstractVector{<:Function}
						 )::Vector{Union{Function,Tuple{String,Vararg}}} 

	fs

end  

function init(fs::Vararg{<:Function,N}
						 )::Vector{Union{Function,Tuple{String,Vararg}}} where N

	out = Vector{Union{Function,Tuple{String,Vararg}}}(undef, N)

	for i=1:N 

		out[i] = fs[i] 

	end 

	return  out 

end 

function init()::Vector{Union{Function,Tuple{String,Vararg}}} 
	
	[]

end 

#############################################################################
end

