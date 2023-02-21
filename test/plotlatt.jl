import PyPlot; 
import myLibs:Lattices 


for a in ["a","b","", "   "], b in ["a","b","", "   "]

	@show myPlots.join_label(a,b)
	@assert myPlots.join_label(a,b)==myPlots.join_label([a,b])==myPlots.join_label((a,b))

end 








error() 








myPlots.split_label(String[])

myPlots.split_label(["A"])
myPlots.split_label(["A","B"])
myPlots.split_label(["A","B","C"])


function do_work(nr_uc::Int,gl::Function)

@show Lattices.LattDim(gl())



	pyscript,plot = myPlots.TypicalPlots.lattice(gl;nr_uc=nr_uc)


	plot(Dict())


	fig,ax = PyPlot.subplots()

	myPlots.pyplot(pyscript,[ax],plot)
	sleep(2) 

	PyPlot.close()

	println()
	println()

end 




for nr_uc in [2,1,0]
println("\n----------------")
@show nr_uc 
println("----------------\n")

for dim in [0,1,2]

	function get_latt(args...; kwargs...)
	
		latt = Lattices.SquareLattice()

		Lattices.Superlattice!(latt, [2,5]) 

		Lattices.KeepDim!(latt,1:dim)

		#Lattices.AddAtoms!(latt, rand(2,1),"X")
	
#		Lattices.AddAtoms!(latt, rand(2,3),"Y")
		

		return latt 
	
	
	end 
	
	
	do_work(nr_uc,get_latt)
	



end 



	function get_latt1(args...;kwargs...)
	
		Lattices.Lattice([10.0 0.0; 0.0 1.0], [-4.5 -3.5 -2.5 -1.5 -0.5 0.5 1.5 2.5 3.5 4.5; 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0], nothing,[2])
	
	end 

	do_work(nr_uc,get_latt1)


end 
	

