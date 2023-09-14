using Revise, Test 

import myPlots

Revise.retry()



for filename in [

#"transf_Fermi_surface",
#
#"myplots", 
#
#"plot_obs",

#"plotlatt",

#"transforms",

"init-sliders",

]



println(" ************ $filename ***********")

include("$filename.jl")



end 








































































































nothing 







































