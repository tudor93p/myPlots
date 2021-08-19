module Transforms
#############################################################################

import LinearAlgebra

import myLibs: Utils, Algebra, ArrayOps, ComputeTasks



using Constants: ENERGIES, VECTOR_STORE_DIM, HOPP_CUTOFF, SYST_DIM




#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#



function get_SamplingVars_(P::AbstractDict, 
													 value::String, 
													 centers::Nothing=nothing,
													 args...)
	nothing

end 

function get_SamplingVars_(P::AbstractDict, 
													 value::String, 
													 centers::AbstractVector{<:Real},
													 key_width::String,
													 key_width_factor::String="no_key_assigned")

	haskey(P, value) || return nothing 


	width = get(P, key_width) do 

			D = diff(Utils.Unique(centers; tol=HOPP_CUTOFF, sorted=true))

			return Algebra.Mean(D)*get(P, key_width_factor, 1)

		end


	return (get(P, "interp_method", :Lorentzian), [P[value]], centers, width) 

end 




function get_SamplingVars(P;	Data=Dict(), get_k=false,
									centers =	get(Data, "Energy", ENERGIES)[:],
									kwargs...
													)

	E_SV = get_SamplingVars_(P, "Energy",
													 get(Data, "Energy", ENERGIES)[:],
													 "E_width",
													 "E_width_factor")

	!get_k && return E_SV 


	k_SV = get_SamplingVars_(P, "k",
													 get(Data, "kLabels", nothing),
													 "E_width",
													 "E_width_factor")


	isnothing(k_SV) && return E_SV 

	return collect(zip(E_SV, k_SV))
	

end







function SamplingWeights(args...; kwargs...)

	a = get_SamplingVars(args...; kwargs...)

	isnothing(a) && return nothing

	return Algebra.getCombinedDistrib(a...; kwargs...)[:]

end


function SampleVectors(vectors, args...; dim=VECTOR_STORE_DIM, kwargs...)
	
	a = get_SamplingVars(args...; kwargs...)

	isnothing(a) && return vectors

	return Algebra.ConvoluteVectorPacket(a..., vectors; dim=dim, kwargs...)

end











#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#

#
#
#function apply_make_scalar(A::AbstractVector{<:Number}, make_scalar::Function
#													)::Number
#
#	make_scalar(A)
#
#end 
#
#function apply_make_scalar(A::AbstractMatrix{<:Number}, 
#													 make_scalar::Function,
#													 )::Vector{<:Number}
#
#	apply_make_scalar(A, make_scalar, VECTOR_STORE_DIM)
#
#end 
#
#
#function apply_make_scalar(A::AbstractArray{<:Number, N}, 
#													 make_scalar::Function,
#													 dim::Int
#													 )::Array{<:Number, N-1} where N
#												
#	ArrayOps.mapslices_dropLostDims(make_scalar, A, dim)
#
#end 


#function apply_convolute(A::AbstractMatrix{<:Number}, 
#												 convolute::AbstractDict, args...
#												)
#
#	apply_convolute(A, v->SampleVectors(v,convolute), args...)
#
#end 
#
#
#function apply_convolute(A::AbstractMatrix{<:Number}, 
#												 convolute::Function)
#	
#	convolute(A)
#
#end 
#
#function apply_convolute(A::AbstractMatrix{<:Number}, 
#												 convolute::Function,
#												 inds::AbstractVector{Int},
#												 dim::Int
#												 )
#
#	ArrayOps.ApplyF_IndsSets(convolute, A, [2,1][dim], inds, dim)
#
#end 
#
#	if inds isa AbstractVector{<:AbstractVector}
#
#		@assert isa(A, AbstractVector) "Wrong dimension"
#	
#		return Utils.Slice_IndsSets(inds, A, 1)
#
#	end 
#
#	return A
#
#end 
#
#
#
#






#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#



function parse_vec2scalar(d::AbstractString)::Function

	d=="Angle" && return R->atan(R[2],R[1])/pi

	d=="Norm" && return LinearAlgebra.norm


	for i in 1:SYST_DIM

		if any(c->occursin(c,d), i-1 .+ ['x', 'X'])


			occursin("norm", d) && return R -> R[i]/LinearAlgebra.norm(R)

			occursin("^2", d) && return R->abs2(R[i])

			return R->R[i]
			
		end 

	end  

	error("Not supported Vec2Scalar: '$d'")

end 






#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#


function Vec2Scalar(data::AbstractVector{<:Number}, args...
									 )::Number 

	Vec2Scalar(Utils.VecAsMat(data, VECTOR_STORE_DIM), 
						 args...)[1]

end 

function Vec2Scalar(data::AbstractMatrix{<:Number}, dim::Nothing,
										args...
									 )::Vector{<:Number}

	Vec2Scalar(data, args...)

end 


function Vec2Scalar(data::AbstractMatrix{<:Number}, P::AbstractDict=Dict()
									 )::Vector{<:Number}
	
	Vec2Scalar(data, [2,1][VECTOR_STORE_DIM], P)

end 


function Vec2Scalar(data::AbstractArray{<:Number, N},
										dim::Int,
										P::AbstractDict=Dict()
										)::Array{<:Number, N-1} where N
															

	haskey(P, "vec2scalar") || return zeros(size(data)[setdiff(1:N,dim)])

	return ArrayOps.mapslices_dropLostDims(parse_vec2scalar(P["vec2scalar"]),
																				 data, dim) 

end







#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#



struct ProcessData 

	check::Union{Bool, Function} 

	calc::Function 

	kwargs::NamedTuple

end 

function ProcessData(calc::Function; kwargs...)

	ProcessData(true, calc, NamedTuple(kwargs))

end  

function ProcessData(check::Function, calc::Function; kwargs...)

	ProcessData(check, calc, NamedTuple(kwargs))

end  

function ProcessData(check_arg::AbstractString, calc::Function; kwargs...)

	check(P::AbstractDict, a...; kwargs...)::Bool = haskey(P, check_arg)

	return ProcessData(check, calc; kwargs...)

end  




function (pd::ProcessData)(P::AbstractDict,
												Data,
												label::Union{AbstractString,
																		 <:AbstractVector{<:AbstractString}
																		 }=String[];
												kwargs...)::Tuple{Any, Vector{String}}

	if (isa(pd.check, Bool) && pd.check) || (
			isa(pd.check, Function) && pd.check(P, Data; pd.kwargs..., kwargs...))

		new_Data, new_label = pd.calc(P, Data; pd.kwargs..., kwargs...)
	
		return (new_Data, vcat(label, string(new_label))) 

	else 

		return (Data, vcat(label))

	end 

end 



#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#





choose_obs_i = ProcessData(
									function check_obs_i(P::AbstractDict, Data; kwargs...)::Bool
										
										haskey(P, "obs_i") && Utils.is_dict_or_JLDAW(Data)

									end,

								 function calc_obs_i(P::AbstractDict, Data; kwargs...) 

									 ComputeTasks.choose_obs_i(Data; P=P, kwargs...)

								 end,
									)

vec2scalar = ProcessData("vec2scalar",
												 
												 function calc_vec2(P::AbstractDict, Data; 
																			 dim=nothing, kwargs...)
													 
													 (Vec2Scalar(Data, dim, P),

														P["vec2scalar"])

												 end)


convol_energy = ProcessData("Energy",
														 
									function calc_chen(P::AbstractDict, Data; kwargs...)

													(SampleVectors(Data, P; kwargs...),

											 "E=" * string(round(P["Energy"],digits=2))
					
											)
					
										end)




#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#


function succesive_transforms(fs::AbstractVector{Symbol},
															P::AbstractDict, 
															Data,
															label::Union{AbstractString,
																					 <:AbstractVector{<:AbstractString}
																					 }=String[];
															kwargs...)

	isempty(fs) && return (Data, label) 

	F = getproperty(@__MODULE__, fs[1])

	return succesive_transforms(fs[2:end], P, F(P, Data, label; kwargs...)...;
															kwargs...)
	
end 













#############################################################################
end

