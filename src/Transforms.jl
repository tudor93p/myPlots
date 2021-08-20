module Transforms
#############################################################################

import LinearAlgebra, FFTW

import myLibs: Utils, Algebra, ArrayOps, ComputeTasks



using Constants: ENERGIES, VECTOR_STORE_DIM, HOPP_CUTOFF, SYST_DIM, MAIN_DIM




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


get_interp_order(r::Nothing=nothing)::Int = 3
get_interp_order(r::Real)::Int = trunc(interp_order)


function interp(x0::AbstractVector{<:Real}, 
								y0::AbstractArray{<:Real,N},
								args...; interp_N::Int=200, dim::Int
								)::Tuple{Vector{Float64},Array{Float64, N}} where N

	interp_order = get_interp_order(args...)	

	x1 = range(extrema(x0)..., length=interp_N)

	return (x1,

					mapslices(y0, dims=dim) do v 
											 
						Algebra.Interp1D(x0, v, interp_order, x1)

					end)
	
end


#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#



function fourier_abs(x::AbstractVector{<:Real},
								 y::AbstractArray{<:Real,N}; 
								dim::Int
								)::Tuple{Vector{Float64},Array{Float64, N}} where N
	
	dist = Utils.Unique(diff(sort(x)), tol=1e-6)

	length(dist)>1 && return fourier_abs(interp(x, y; dim=dim)...; dim=dim)

	return (

				 FFTW.rfftfreq(length(x), 2pi/(x[2]-x[1])),
			
				 abs.(mapslices(FFTW.rfft, y, dims=dim))
			
				 )

end 

#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#
function argmax_fourier_abs(x::AbstractVector{<:Real},
														y::AbstractVector{<:Real}; 
														kwargs...)::Real 

	x1, y1 = fourier_abs(x, y; dim=1)

	return x1[argmax(y1)]

end 







function argmax_fourier_abs(x::AbstractVector{<:Real},
								 y::AbstractArray{<:Real,N};
								dim::Int
								)::Array{Float64, N-1} where N

	x1, y1 = fourier_abs(x, y; dim=dim)

	return dropdims(mapslices(yi->x1[argmax(yi)], y1; dims=dim), dims=dim)

end 


#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#


function fourier_comp(V::AbstractVector{<:Number}, freq::Real;  
											kwargs...)::Vector{ComplexF64}

	Algebra.fft(V, freq; addup=false)[1,:]

end 

function fourier_comp(A::AbstractMatrix{<:Number}, freq::Real;  
											dim::Int, kwargs...)::Matrix{ComplexF64}

	Algebra.fft(A, freq; addup=false, dim=dim)

end 


#function fourier_comp(a::AbstractVecOrMat, freq::Real; dim::Int, rtol=0)
#
#	A = real(Algebra.fft(a, freq, addup=false, dim=dim)) 
#	
#	rtol>0 && Utils.ReplaceByNeighbor!(isapprox(0, atol=rtol*maximum(abs,A)), A)
#
#	return sign.(A)
#
#end 


#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#

#=
function plothelper_transform(P, x, y, xlab=nothing; dim=1, interp_N=200)

	out(A, B, L) = (collect(A), collect(B), L)

	transf = get(P, "transform", "None")

	transfparam = get(P, "transfparam", nothing)


	elseif transf=="Fourier comp."

		freq = Utils.Assign_Value(transfparam,0)*2pi
		
		y1 = find_Fourier_components(y, freq; dim=dim, rtol=get(P, "smooth", 0)/100)

		




		return out(x, y1, xlab) # don't input label !!

	end 

end



=#

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
# Functions which reduce structure
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


#choose_argmax_Fourier = ProcessData


#===========================================================================#
#
# Functions which keep data structure 
#
#---------------------------------------------------------------------------#



transform = ProcessData(
												
								function check_transf(P::AbstractDict, Data; kwargs...)

									get(P, "transform", "None") in ["|Fourier|","Interpolate",
																									"Fourier comp."]

								end,

								function calc_transf(P::AbstractDict, (x,y); kwargs...)

									transf = P["transform"]
	
									if transf=="Interpolate" 

										transfparam = get(P, "transfparam", nothing)

										return (interp(x, y, transfparam; kwargs...), "interp.")

									elseif transf=="|Fourier|"

										return (fourier_abs(x, y; kwargs...), "|FFT|")

									elseif transf=="Fourier comp." 
		
										freq = get(P, "transfparam", 0) 

										lab = round(freq, digits=1)  

										return ((x, fourier_comp(y, freq*pi; kwargs...)),

														"Fcomp($lab"*"pi)"
														)
									end 

								end 

								)






#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#





function dist_dw_label(Rs::AbstractVector{<:Number})::Vector{String}

	dist_dw_label.(Rs)

end 

function dist_dw_label(R::Number)::String 

	string(["x","y"][MAIN_DIM], "=", round(R, digits=1))

end  


closest_to_dw = ProcessData(

				function just_slice(P::AbstractDict, A::AbstractArray{<:Number, N};
														R::Number, inds::AbstractVector{Int}, dim::Int 
														)::Tuple{AbstractArray{<:Number,N}, String} where N

								(selectdim(A, dim, inds), dist_dw_label(R))


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

