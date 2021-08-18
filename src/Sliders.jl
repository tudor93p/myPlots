module Sliders
#############################################################################



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

		merge!(union, d, Dict("Vec2Scalar" => map(string, [																				
			collect(Base.product('x' .+ (0:SYST_DIM-1),[""," norm.","^2"]))[:];
			 "Angle"; "Norm";
			 
			])))

	end 










#############################################################################
end

