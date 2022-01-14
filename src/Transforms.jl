module Transforms
#############################################################################

import LinearAlgebra, FFTW

import myLibs: Utils, Algebra, ArrayOps, ComputeTasks


using Constants: ENERGIES, VECTOR_STORE_DIM, COMP_STORE_DIM
using Constants: HOPP_CUTOFF, SYST_DIM, MAIN_DIM




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


		return (get(P, "interp_method", :Lorentzian), 
						vcat(P[value]), centers, width) 

end 




function get_SamplingVars(P;	Data=Dict(), get_k::Bool=false,
									centers =	get(Data, "Energy", ENERGIES)[:],
									kwargs...
													)

	E_SV = get_SamplingVars_(P, "Energy",
													 get(Data, "Energy", ENERGIES)[:],
													 "E_width",
													 "E_width_factor")

	get_k || return E_SV 

	haskey(P, "k") || return E_SV

	haskey(P, "k_width") || return E_SV 

	haskey(Data, "kLabels") || return E_SV 

	k_SV = get_SamplingVars_(P, "k",
												 get(Data, "kLabels", nothing),
													"k_width",
													 haskey(P,"k_width_factor") ? "k_width_factor" : "E_width_factor",)



	return collect(zip(E_SV, k_SV))
	

end







function SamplingWeights(args...; kwargs...)

	a = get_SamplingVars(args...; kwargs...)

	isnothing(a) && return nothing

	return Algebra.getCombinedDistrib(a...; kwargs...)

end

function SampleVectors(vector::AbstractVector{T}, args...; 
											 kwargs...)::Vector{T} where T<:Number 

	SampleVectors(Utils.VecAsMat(vector, 1), args...;
								dim=2, kwargs...) |> vec

end 

function SampleVectors(vectors::AbstractMatrix{T}, args...; 
											 dim=VECTOR_STORE_DIM, kwargs...
											 )::Matrix{T} where T<:Number
	
	a = get_SamplingVars(args...; kwargs...)

	isnothing(a) && return vectors

	return Algebra.ConvoluteVectorPacket(a..., vectors; dim=dim, kwargs...)

end




function SampleVectors(A::AbstractArray{T,N}, args...; dim::Int,
											 kwargs...)::Array{T,N} where T<:Number where N

	B = if dim==1 

		SampleVectors(reshape(A, size(A,1), :), args...; dim=1, kwargs...)

			elseif dim==N

		SampleVectors(reshape(A, :, size(A,N)), args...; dim=2, kwargs...)

			else 

				mapslices(A,dims=(dim-1,dim)) do vectors 

					SampleVectors(vectors, args...; dim=2, kwargs...)

				end 

			end 


	return reshape(B, (d==dim ? 1 : size(A,d) for d=1:N)...)

end 



#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#

function nr2str(nr::Real)::String 

	x = string(round(nr,digits=2))

	return occursin(".",x) ? rstrip(rstrip(x,'0'),'.') : x

end 


function get_restrict_oper(m::Real, M::Real)::Tuple{Function,String}

	r(x::Real)::Bool = m<=x<=M

	label = string("in[",nr2str(m),",",nr2str(M),"]")

	return r,label

end 

function get_restrict_oper(m::Real, ::Nothing)::Tuple{Function,String}

	r(x::Real)::Bool = m<=x
	
	label = string(">",nr2str(m))
	
	return r,label 

end  

function get_restrict_oper(::Nothing, M::Real)::Tuple{Function,String}

	r(x::Real)::Bool = x<=M
	
	label = string("<",nr2str(M))
	
	return r,label 

end 

function get_restrict_oper(::Nothing, ::Nothing)::Tuple{Nothing,String}
	
	nothing, ""

end 


function get_restrict_oper(P::AbstractDict)::Tuple{Union{Nothing,Function},
																									 String}

	get(P, "filterstates", false) || return (nothing,"")

	return get_restrict_oper(get.([P], ["opermin","opermax"], [nothing])...)

end


function iFilterStates(P::AbstractDict, 
											 v::Union{AbstractVector,Base.Generator}
											 )::Tuple{Union{BitVector,Colon},String}

	f,label = get_restrict_oper(P)

	if isnothing(f) 
		
		return Colon(),label

	else 


		return f.(v),label

	end 

end 

#function FilterStates(P::AbstractDict,
#											(v0,v,d)::Tuple{AbstractVector, AbstractMatrix, Int}
#											)
#
#	selectdim(v, d, iFilterStates(P, v0))
#
#end 
#
#
#function FilterStates(P::AbstractDict,
#											(v,d)::Tuple{AbstractMatrix,Int}
#											)
#
#	FilterStates(P, (eachslice(v, dims=d), v, d))
#
#end 

function FilterStates(P::AbstractDict,
											args::Tuple{Union{AbstractVector,Base.Generator},
																	Vararg}
											)::Tuple{Vector{<:AbstractArray},String}

	FilterStates(P, args[1], args[2:end]...)

end 

function FilterStates(P::AbstractDict,
											v0::Union{AbstractVector,Base.Generator},
											args...
											)::Tuple{Vector{<:AbstractArray},String}

	for (i,a) in enumerate(args)

		if a isa AbstractArray 

			N = ndims(a)

			@assert N>0

			N==1 && i<length(args) && @assert args[i+1] isa AbstractArray 

			N>1 && @assert i<length(args) && args[i+1] isa Int && args[i+1] in 1:N

		elseif a isa Int 

			@assert i>1 && args[i-1] isa AbstractArray && a in 1:ndims(args[i-1]) 
	
		else 

			error()

		end 

	end 

	inds_kept_states,label = iFilterStates(P, v0) 


	arrays = map(findall(isa.(args,AbstractArray))) do i

		ndims(args[i])==1 && return args[i][inds_kept_states]
			
		return selectdim(args[i], args[i+1], inds_kept_states) 

	end  

	return arrays, label

end 


#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#

function label_convol_en(P::AbstractDict)::String 

	"E=" * nr2str(P["Energy"])

end 


function DOSatEvsK1D(P::AbstractDict, Data::AbstractDict, label...;
										 ks::AbstractVector{<:Real}, kwargs...
										 )::Tuple{Tuple{Vector{Float64},
																		Matrix{Float64}},
															Vector{String}}

	weights = SamplingWeights(Utils.adapt_merge(P, "k"=>ks); 
														Data=Data, get_k=true)

	DOS = dropdims(sum(weights, dims=2), dims=2) 
	
	return ( (DOS, weights), vcat(label..., label_convol_en(P)))

end 


function DOSatEvsK1D(P::AbstractDict,
										 (Data,oper)::Tuple{<:AbstractDict,<:AbstractString},
										 label...;
										 ks::AbstractVector{<:Real}, 
										 restrict_oper::Bool=false,
										 normalize::Bool=true, kwargs...
										 )::Tuple{Tuple{Vector{Float64},
																		<:Union{Nothing,Array{Float64}}},
															Vector{String}} #where T<:AbstractMatrix{Float64}

	(DOS, w), lab1 = DOSatEvsK1D(P, Data, label...; ks=ks)


	haskey(Data, oper) || return (DOS, nothing), lab1




	function prep_sizes(v::AbstractVector{Float64}, c)::Tuple#{T,T,Function}
	
		prep_sizes(Utils.VecAsMat(v, COMP_STORE_DIM), c, Val(true))

	end 


	function prep_sizes(v::AbstractMatrix{Float64}, c::AbstractMatrix{Float64}, 
											reduce_dim::Val=Val(false)
											)::Tuple#{T,T,Function}

		@assert size(c)==(length(DOS),size(v,VECTOR_STORE_DIM)) 
		# (nr_ks, nr_eigenstates)

		return v, (VECTOR_STORE_DIM==1 ? c : transpose(c)), reduce_dim

	end 


	prep_states(v, c, reduce_dim::Val, ::Val{false}) = ((v,c), "", reduce_dim)


	function prep_states(v, c, reduce_dim::Val{false}, ::Val{true})

		(FilterStates(P, eachslice(v, dims=VECTOR_STORE_DIM),
									v, VECTOR_STORE_DIM, c, COMP_STORE_DIM)...,
		 reduce_dim)

	end 


	function prep_states(v, c, reduce_dim::Val{true}, ::Val{true})

		(FilterStates(P, selectdim(v, COMP_STORE_DIM, 1),
									v, VECTOR_STORE_DIM, c, COMP_STORE_DIM)...,
		 reduce_dim)

	end 

	function normalize_distrib((Z,W))

		dos2 = sum(W, dims=COMP_STORE_DIM)

		W2 = Algebra.normalizeDistrib(W, dos2, normalize)

		return dropdims(dos2, dims=COMP_STORE_DIM), (Z,W2)
	end


	function zeroout(v, c, ::Val{false})

		outshape = [0, 0]

		outshape[COMP_STORE_DIM] = size(v, COMP_STORE_DIM) 

		outshape[VECTOR_STORE_DIM] = size(c, VECTOR_STORE_DIM) 

		return zeros(outshape...) 

	end   

	zeroout(v, c, ::Val{true}) = zeros(size(c, COMP_STORE_DIM))



	#linear combinations of the vectors in z with coefficients weights 

	function CombsOfVecs(vc, ::Val{false}=Val(false))

		Utils.CombsOfVecs(vc...; dim=VECTOR_STORE_DIM)

	end  


	function CombsOfVecs(vc, ::Val{true})

		selectdim(CombsOfVecs(vc), COMP_STORE_DIM, 1)

	end 



#	nr_states=size(vecs,VECTOR_STORE_DIM)==size(coeffs,COMP_STORE_DIM)
#	dimension==size(vecs,COMP_STORE_DIM) == size(out, COMP_STORE_DIM)
#	nr_combs==size(coeffs,VECTOR_STORE_DIM) == size(out,VECTOR_STORE_DIM)
#	nr_combs==length(DOS)==length(ks)


	z, lab2 = choose_color_i(P, Data[oper], vcat(lab1, oper); kwargs...) 

	zw, lab3, reduce_dim = prep_states(prep_sizes(z, w)..., Val(restrict_oper))

#	print(Int(round(100*length(zw[2])/length(w)))," ")


	lab4 = vcat(lab2, lab3)

	if any(isempty, zw)

		return (zeros(size(w,COMP_STORE_DIM)), zeroout(z,w,reduce_dim)), lab4

	else 

		DOS2, ZW = normalize_distrib(zw)

#		@assert xor(restrict_oper, isapprox(DOS2,DOS))

		return (DOS2, CombsOfVecs(ZW, reduce_dim)), lab4 

	end 


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

function Vec2Scalar(data::AbstractMatrix{<:Number}, ::Nothing, args...
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
								smooth=0.0,
								kwargs...
								)::Tuple{Vector{Float64},Array{Float64, N}} where N


	x1 = range(extrema(x0)..., length=interp_N)

	N==1 && return (x1, Algebra.Interp1D(x0, y0, interp_order, x1; s=smooth))


	return (x1, mapslices(y0, dims=kwargs[:dim]) do v 
											 
						Algebra.Interp1D(x0, v, interp_order, x1; s=smooth)

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


	good(::Nothing)::Bool = false 

	good(S::Symbol)::Bool = good(string(S))

	good(s::AbstractString)::Bool = !isempty(s) && s!="nothing"

	good(X)::Bool = isempty(X) ? false : good(string(X))


	return (new_Data, string.(filter!(good, vcat(label, new_label))))
	
end 



#===========================================================================#
#
# Functions which reduce structure
#
#---------------------------------------------------------------------------#

choose_obs_i = ProcessData(

		function check_obs_i(P::AbstractDict, Data; kwargs...)::Bool
						
			haskey(P, "obs_i") || haskey(kwargs, :f)
						
		end,

		function calc_obs_i(P::AbstractDict, Data; kwargs...) 

			ComputeTasks.choose_obs_i(Data; P=P, kwargs...)

		end,
					) 





choose_color_i = ProcessData(choose_obs_i.check,

	function calc_cci(P::AbstractDict, z::AbstractArray{T}; kwargs...
										)::Tuple{Array{T},Any} where {T<:Real}
	
		z1 = dropdims(z, dims=Tuple(findall(size(z).==1)))
	
		ndims(z1)==0 && return [only(z1)], ""
	
		ndims(z1)==1 && return z1, ""
	
		D = eachslice(z1, dims=Dict(1=>ndims(z1), 2=>1)[VECTOR_STORE_DIM])
	
		return ComputeTasks.choose_obs_i(Dict(enumerate(D)); P=P, kwargs...)
	
	end 
	
	 )





vec2scalar = ProcessData("vec2scalar",
												 
												 function calc_vec2(P::AbstractDict, Data; 
																			 dim=nothing, kwargs...)
													 
													 (Vec2Scalar(Data, dim, P),

														P["vec2scalar"])

												 end)


convol_energy = ProcessData("Energy",
														 
									function calc_chen(P::AbstractDict, Data; kwargs...)

										(SampleVectors(Data, P; kwargs...), label_convol_en(P))
					
									end) 


convol_DOSatEvsK1D = ProcessData("Energy", DOSatEvsK1D)

filter_states = ProcessData("filterstates", FilterStates)


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

pd_smoothinterp = ProcessData("transform", "SmoothInterp.",

		function calc_sm_interp(P::AbstractDict, (x,y); kwargs...)

					N = max(2length(x), parse_integer(get(P, "transfparam", 10)))

					return interp(x, y; interp_N=N, smooth=get(P,"smooth",0),
												kwargs...), "smooth interp."

		end 

		)



pd_fourier = ProcessData("transform", "|FFT|",
												  
		function calc_fourier(P::AbstractDict, (x,y); kwargs...)

			fourier_abs(x, y; kwargs...), "|FFT|"

		end
		)


pd_interp_fourier = ProcessData("transform", "Interp.+|FFT|",

		function calc_if(P::AbstractDict, (x,y); kwargs...)

			N = max(2length(x), parse_integer(get(P, "transfparam", 10)))
		
			return interp_and_fourier_abs(x,y; interp_N=N, kwargs...), "i|FFT|"

		end)


pd_sm_interp_fourier = ProcessData("transform", "SmoothInterp.+|FFT|",

		function calc_sif(P::AbstractDict, (x,y); kwargs...)

			N = max(2length(x), parse_integer(get(P, "transfparam", 10)))
		
			return interp_and_fourier_abs(x,y; interp_N=N, 
																		smooth=get(P,"smooth",0), 
																		kwargs...), "si|FFT|"

		end)


pd_fourier_comp = ProcessData("transform", "FourierComp.",

		function calc_fc(P::AbstractDict, (x,y); kwargs...)

			freq = get(P, "transfparam", 0)::Real 

			lab = nr2str(freq)*"pi"

			return (x, fourier_comp(y, freq*pi; kwargs...)), "Fcomp($lab)"

		end)
#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#



function ProcessData(pds::Vararg{ProcessData}; kwargs0...)::ProcessData

	function find_pd(args...; kwargs...)::Tuple{Vararg{ProcessData}}

		n = filter(pd->check_pd(pd, args...; kwargs...), pds)
	
		@assert length(n)<=1 n

		return n

	end 


	function one_calc(args...; kwargs...)

		find_pd(args...; kwargs...)[1].calc(args...; kwargs...)

	end 

	return ProcessData(!isempty ∘ find_pd, one_calc, NamedTuple(kwargs0))

end 







transform = ProcessData(pd_fourier_comp, 
												pd_interp, 
												pd_smoothinterp,
												pd_fourier, 
												pd_interp_fourier,
												pd_sm_interp_fourier,
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

	string(["x","y"][MAIN_DIM], "=", nr2str(R))

end  


closest_to_dw = ProcessData(

				function just_slice(P::AbstractDict, A::AbstractArray{T, N};
														R::Number, inds::AbstractVector{Int}, kwargs... 
														)::Tuple{Array{T,N}, String} where {T<:Number, N}

					(collect(selectdim(A, N==1 ? 1 : kwargs[:dim], inds)), 
					 dist_dw_label(R))


				end)




#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#


function successive_transforms(fs::AbstractVector{Symbol},
															P::AbstractDict, 
															Data,
															label::Union{AbstractString,
																					 <:AbstractVector{<:AbstractString}
																					 }=String[];
															kwargs...)

	isempty(fs) && return (Data, label) 

	F = getproperty(@__MODULE__, fs[1])
#successive
	return successive_transforms(fs[2:end], P, F(P, Data, label; kwargs...)...;
															kwargs...)
	
end 













#############################################################################
end

