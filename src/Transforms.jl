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


parse_integer(r::Nothing=nothing)::Int = 0
parse_integer(r::Real)::Int = trunc(r)


function interp(x0::AbstractVector{<:Real}, 
								y0::AbstractArray{<:Real,N},
								interp_order::Int=3; 
								interp_N::Int=200,  
								kwargs...
								)::Tuple{Vector{Float64},Array{Float64, N}} where N


	x1 = range(extrema(x0)..., length=interp_N)

	N==1 && return (x1, Algebra.Interp1D(x0, y0, interp_order, x1))


	return (x1, mapslices(y0, dims=kwargs[:dim]) do v 
											 
						Algebra.Interp1D(x0, v, interp_order, x1)

					end)
	
end


#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#

#function fourier_abs(x::AbstractVector{<:Real},
#								 y::AbstractVector{<:Real}; kwargs...
#								)::Tuple{Vector{Float64},Vector{Float64}}
#
#
#	x1, y1 = fourier_abs(x, Utils.VecAsMat(y,1); dim=2)
#
#	return (x1, vec(y1))
#
#end 


function fourier_freq(x::AbstractVector{<:Real}; check_step::Bool=true)::Vector{Float64}

	if check_step 

		D = diff(x)
	
		@assert all(D.>0)

		dist = Utils.Unique(D, tol=1e-6)

		#length(dist)>1 && return fourier_abs(interp(x, y; dim=dim)...; dim=dim)
	
		@assert length(dist)==1

	end 

	return FFTW.rfftfreq(length(x), 2pi/(x[2]-x[1]))

end 

#function apply_VecOrArray(f::Function, y::AbstractVector{<:Number}; kwargs...)
#	
#		f(y) : mapslices(f, y, dims=kwargs[:dim])
#
#end 

function fourier_abs(x::AbstractVector{<:Real},
								 y::AbstractArray{<:Real,N}; 
								 kwargs...
								)::Tuple{Vector{Float64},Array{Float64, N}} where N
	
	(fourier_freq(x),
	 
	 abs.(N==1 ? FFTW.rfft(y) : mapslices(FFTW.rfft, y, dims=kwargs[:dim]))

	 )

end 


function interp_and_fourier_abs(x::AbstractVector{<:Real},
																y::AbstractArray{<:Real,N};
																kwargs...
																)::Tuple{Vector{Float64},Array{Float64, N}} where N
	
	k = fourier_freq(x) 

	ki, Ai = fourier_abs(interp(x, y; kwargs...)...; kwargs...)

	return k, selectdim(Ai, N==1 ? 1 : kwargs[:dim], axes(k,1))

end 

#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#


function get_freq_max(x::AbstractVector{<:Real},
											y::AbstractVector{<:Real})::Real 
	x[1+ argmax(y[2:end])]

end 

function get_freq_max(x::AbstractVector{<:Real})::Function 
	
	gfm(y::AbstractVector{<:Real})::Real = get_freq_max(x, y) 

end 


function dominant_freq(x::AbstractVector{T},
														y::AbstractVector{<:Real};
														interpolate::Bool=false,
														kwargs...)::T where T<:Real

	f = interpolate ? interp_and_fourier_abs : fourier_abs

	return get_freq_max(f(x, y; kwargs...)...)

end 


function dominant_freq(x::AbstractVector{T},
								 y::AbstractArray{<:Real,N};
								 interpolate::Bool=false,
								dim::Int, kwargs...
								)::Array{T, N-1} where {T<:Real,N}

	f = interpolate ? interp_and_fourier_abs : fourier_abs

	x1, y1 = f(x, y; dim=dim, kwargs...)

	return dropdims(mapslices(get_freq_max(x1), y1; dims=dim), dims=dim)

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


function ProcessData(check_arg1::AbstractString, check_arg2::AbstractString,
										 calc::Function; kwargs...)

	function check(P::AbstractDict, a...; kwargs...)::Bool 
		
		haskey(P, check_arg1) && P[check_arg1]==check_arg2

	end 

	return ProcessData(check, calc; kwargs...)

end  


function check_pd(pd::ProcessData, args...; kwargs...)::Bool

	isa(pd.check, Bool) && pd.check && return true 

	isa(pd.check, Function) && pd.check(args...; pd.kwargs..., kwargs...)

end 

function (pd::ProcessData)(P::AbstractDict,
												Data,
												label::Union{AbstractString,
																		 <:AbstractVector{<:AbstractString}
																		 }=String[];
												kwargs...)::Tuple{Any, Vector{String}}

	check_pd(pd, P, Data; kwargs...) || return (Data, vcat(label))

	new_Data, new_label = pd.calc(P, Data; pd.kwargs..., kwargs...)

	return (new_Data, vcat(label, string(new_label))) 

end 



#===========================================================================#
#
# Functions which reduce structure
#
#---------------------------------------------------------------------------#

choose_obs_i = ProcessData(
									function check_obs_i(P::AbstractDict, Data; kwargs...)::Bool
										
										Utils.is_dict_or_JLDAW(Data) || return false 

										return haskey(P, "obs_i") || haskey(kwargs, :f)
										
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
# Functions which keep data structure 
#
#---------------------------------------------------------------------------#

pd_interp = ProcessData("transform", "Interpolate",

		function calc_interp(P::AbstractDict, (x,y); kwargs...)

					N = max(2length(x), parse_integer(get(P, "transfparam", 10)))

					return interp(x, y; interp_N=N, kwargs...), "interp."

		end 

							)

pd_fourier = ProcessData("transform", "|Fourier|",
												  
		function calc_fourier(P::AbstractDict, (x,y); kwargs...)

			fourier_abs(x, y; kwargs...), "|FFT|"

		end
		)


pd_interp_fourier = ProcessData("transform", "Interp.+|FFT|",

		function calc_if(P::AbstractDict, (x,y); kwargs...)

			N = max(2length(x), parse_integer(get(P, "transfparam", 10)))
		
			return interp_and_fourier_abs(x,y; interp_N=N, kwargs...), "i|FFT|"

		end)


pd_fourier_comp = ProcessData("transform", "Fourier comp.",

		function calc_fc(P::AbstractDict, (x,y); kwargs...)

			freq = get(P, "transfparam", 0)::Real 

			lab = round(freq, digits=1)  

			return (x, fourier_comp(y, freq*pi; kwargs...)), "Fcomp($lab"*"pi)"

		end)
#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#



function ProcessData(pds::Vararg{ProcessData}; kwargs0...)::ProcessData

	function find_pd(args...; kwargs...)::Tuple{Vararg{ProcessData}}

		n = filter(pd->check_pd(pd, args...; kwargs...), pds)
		
		@assert length(n)<=1 

		return n

	end 

	function any_check(args...; kwargs...)::Bool

		!isempty(find_pd(args...; kwargs...))

	end 

#any_check = (!isempty) ∘ find_pd 

	function one_calc(args...; kwargs...)

		find_pd(args...; kwargs...)[1].calc(args...; kwargs...)

	end 

	return ProcessData(any_check, one_calc, NamedTuple(kwargs0))

end 







transform = ProcessData(pd_fourier_comp, 
												pd_interp, 
												pd_fourier, 
												pd_interp_fourier)







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

