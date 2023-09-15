import myPlots 
import myLibs:Operators 

@testset "i outside" begin 

	x = rand(3)

	for (j,c) in enumerate('x':'z')
		w = myPlots.Transforms.parse_vec2scalar(c)

		i = rand() 

		@test x[j]≈w(x)

	end 


end 



@testset "vec2scalar functions" begin 

for s in myPlots.Sliders.py_vec2scalar()

	@show s 

#	@show myPlots.Transforms.get_vec2scalar_fstr(s)


	w = myPlots.Transforms.parse_vec2scalar(s) 

	@show w


	for q in [1, rand(3), rand(2,3,4), rand(2,3)]

		hasmethod(w,(typeof(q),)) && w(q)
		applicable(w,q) && w(q)

	end 

#	@test applicable(w,rand(3))
#	@test !applicable(w,rand(5,3))

	@test w(rand(3)) isa Real 

	@show w([1,2,3])
	println() 

end  

end 



@testset "operators" begin 

	atoms = rand(2,100);

	operator_names = ["X","|Y|","IPR","LocalDOS","X^2"]

	kwargs = (nr_at=size(atoms,2), nr_orb=4, dim=2)

	operator_functions = map(operator_names) do n 

		d,f = myPlots.Transforms.parse_fstr_Cartesian(n)

		d>0 && return Operators.Position(d, atoms; kwargs..., fpos=f)

		for (N,S) in (("LocalDOS",:LDOS),("IPR",:IPR))

			n==N && return getfield(Operators, S)(; kwargs...)

		end 

		error(n)

	end  

	for f in operator_functions 

		@test size(f(rand(400,3)),2)==3

	end 




end 







