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



function pick_nonlocal(obs_list)

	rest = copy(obs_list)

	for f in [pick_local, pick_bondvector, pick_sitevector]

		setdiff!(rest, f(obs_list))

	end

	return rest


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

			(max(minimum(a),minimum(b)), min(maximum(a),maximum(b)))

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
																		"FourierComp."
																		)


#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#


function init(f::Symbol, args...)::Vector{Function}

	F = Utils.getprop(@__MODULE__, f, 
										Utils.getprop(@__MODULE__, Symbol(string("init_",f))))

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

