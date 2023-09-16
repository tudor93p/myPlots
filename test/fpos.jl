import myPlots: Transforms 
import myLibs: Operators 


function foo()

atoms = rand(2,10) 

n = "x"

d,f = Transforms.parse_fstr_Cartesian(n)



kwargs = (nr_at=size(atoms,2), nr_orb=4, dim=2)

Operators.Position(d, atoms; kwargs..., fpos=f) 


end 


foo()
