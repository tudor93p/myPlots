import PyPlot; 
import myLibs:Lattices


for dim in [0,1,2]

	function get_latt(args...; kwargs...)
	
	
		latt = Lattices.Superlattice(Lattices.SquareLattice(), [6,1])

	
	

		Lattices.AddAtoms!(latt, rand(2,1),"X")
	
	
#		Lattices.AddAtoms!(latt, rand(2,3),"Y")
		
		for d in 1:dim 

#			Lattices.ReduceDim!(latt,1)

		end  

		latt.LattDims = 1:2-dim
#		latt.LattDims = 1+dim:2 

		latt.LattVec = latt.LattVec[:,1+dim:2]
	
		return latt 
	
	
	end 
	


	@show Lattices.LattDim(get_latt())


	pyscript,plot = myPlots.TypicalPlots.lattice(get_latt;nr_uc=0)


	plot(Dict())

#	fig,ax = PyPlot.subplots()

#	myPlots.pyplot(script,[ax],plot)




end 

