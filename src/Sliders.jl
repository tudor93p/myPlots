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


function retrieve_function(f::Symbol,
													 prefix::Union{Char,AbstractString,Symbol}
													 )::Function  

	Utils.getprop(@__MODULE__, f,
								Utils.getprop(@__MODULE__, Symbol(string(prefix,f)))
								)
 
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

	#tex(s) = "\$$s\$"

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


#function retrieve_function(f::Symbol)::Function 
#
#	Utils.getprop(@__MODULE__, f)
#
#
#end 


function init(f::Symbol, args...)::Vector{Function}

	F = retrieve_function(f,"init_")

	@assert F isa Function 

	return [F(args...),]

end 

init(t::Tuple)::Vector{Function} = init(t...)

init(tuples::Vararg{Tuple})::Vector{Function} = vcat(init.(tuples)...)

init(tuples::AbstractVector{<:Tuple})::Vector{Function} = init(tuples...)


init(f::Function)::Vector{Function}  = [f]

init(fs::AbstractVector{<:Function})::Vector{Function} = fs

init(fs::Vararg{<:Function})::Vector{Function} = vcat(fs...)

init()::Vector{Function} = Function[] 

#############################################################################
end

