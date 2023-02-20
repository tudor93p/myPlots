using Revise, Test 

import myPlots

Revise.retry()

for filename in [

"transf_Fermi_surface",

"myplots", 

"plot_obs",

"plotlatt",

"transforms",

"init-sliders",

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







































