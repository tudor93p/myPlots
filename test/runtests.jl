using Revise, Test 

import myPlots

for filename in [

#"transf_Fermi_surface",

"myplots",

]



println(" ************ $filename ***********")

include("$filename.jl")


end



#include("plotlatt.jl")

#include("transforms.jl")




#include("Fourier_Freq.jl")


#include("choose-obs.jl")

#include("plot_obs.jl")















































































































nothing 







































