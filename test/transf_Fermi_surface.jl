println() 
import Random, LinearAlgebra
import myLibs:Utils 

T = myPlots.Transforms

@testset "Filter states" begin 

	P = Dict("opermin"=>0, "filterstates"=>true)

	v = rand(2,10) .- 0.5

	c = rand(10,5)

	d1,d2 = 2,1 

	v0 = first.(eachslice(v, dims=d1))

	inds,label = T.iFilterStates(P, v0)

	@show count(inds) label 

	v1 = rand(10)

	X,label2 = T.FilterStates(P, v0, v, d1, v1, v, d1, c, d2)

	Y,label3 = T.filter_states(P, (v0, v, d1, v1, v, d1, c, d2), "test")

	@test label==label2 
	@test label==label3[end]

#	@show label3 


	@test length(X)==length(Y)==4

	for x in [X,Y]

		@show length(x) 

		@test isapprox(x[1],selectdim(v, d1, inds))
		@test isapprox(x[2],v1[inds])
		@test isapprox(x[3],selectdim(v, d1, inds))
		@test isapprox(x[4],selectdim(c, d2, inds))
	
	end 





	P2 = Dict("opermin"=>0)#, "filterstates"=>true)


	Z,label4 = T.filter_states(P2, (v0, v, d1, v1, v, d1, c, d2), "test")
	
	@test length(Z)==4 
	@test length(label4)==1 && only(label4)=="test"

	for (a,b) in zip(Z, (v, v1, v, c))

		@test a≈b

	end 






end 



println()














@testset "Fermi surface" begin 

P = Dict("Energy"=>rand(),"k_width"=>0.1)

Data=Dict{String,Any}("Energy"=>sort(rand(100)),"kLabels"=>sort(rand(100)))
ks = sort(rand(47)) 

(DOS,Z),label = T.convol_DOSatEvsK1D(P, Data; ks=ks)

#@show label 
@test Z isa AbstractMatrix && size(Z)==(47,100) 

@test size(DOS)==(47,)



(DOS,Z),label2 = T.convol_DOSatEvsK1D(P, (Data,"X"); ks=ks, vsdim=2)

@test label==label2

@test isnothing(Z)

@test size(DOS)==(47,)


Data["X"]= rand(2,100).-0.5

P["obs_i"]=2

(DOS,Z),label3 = T.convol_DOSatEvsK1D(P, (Data,"X"); ks=ks,f="first",vsdim=2)



@test length(DOS)==length(Z)==47 

#@show label3
println()


Data["X"]= rand(100).-0.5

(DOS,Z),label3 = T.convol_DOSatEvsK1D(P, (Data,"X"); ks=ks,f="first",vsdim=2)


@test length(DOS)==length(Z)==47 


### 
println("\n------\n")

Random.seed!(abs(Int(round(1000time())-1000round(time()))))


nr_states= rand(30:200)
nr_ks = rand(20:nr_states)

@show nr_ks nr_states 

oper = "X"

ks = sort(rand(nr_ks)) 

for oper_comp in ([],[1],[2]),normalize in [true,false]
	for add in [["obs_i"=>1]],k in ["opermin","opermax"], restrict_oper in [true,false]

		Data=Dict{String,Any}("Energy"=>sort(rand(nr_states)).-0.5,
													"kLabels"=>sort(rand(nr_states)).-0.5,
													oper=> rand(oper_comp..., nr_states).-0.5,
																					)
		
		P = Dict("Energy"=>rand(),"k_width"=>0.1,"filterstates"=>true)

	V = []


	#println()
	for x0 in range(-0.6,0.6,length=10)



#		restrict_oper =  x->any(x.>x0)
#		restrict_oper =  x->all(x.>x0)

	
	## 
	
	
	

#		println("\n*****")

#		@show oper_comp
#		@show add 

p = Utils.adapt_merge(P, add..., k=>x0)#, "opermax"=>1)
	
(DOS,Z),label = T.convol_DOSatEvsK1D(p, (Data, oper); ks=ks, normalize=normalize, restrict_oper=restrict_oper, vsdim=2)

#		@show label 
		@test length(DOS)==nr_ks 
	
		@test size(Z)[end]==nr_ks 
	
#		@show size(Z) label 

		push!(V,LinearAlgebra.norm(Z))

	end 


#	println()

#	println(round.(V,digits=2))

#		error() 
#

#restrict_oper = >=(0)

#@show label3

end  end 


println()

end 




