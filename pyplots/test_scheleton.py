import numpy as np  
import json 

import Utils 

import scheleton  
import test_vectorfield, test_scatter, test_Z

pyplot_merged_Param = (["a","b","c"], 
                        [[0,1,2], np.linspace(0,3,100), ["c1","c2"]]
                        )


pyplot_pyjl_pairs = [
        ["Scatter",test_scatter.get_plotdata,"test1"],
        ["VectorField", test_vectorfield.get_plotdata, "test2"],
        ["Z_vsX_vsY", test_Z.get_plotdata, "test3"],
        ]

insets = {1:2}

pyplot_init_sliders = {"enlim":[-1,2]} 

pyplot_extra_sliders = ["choose_k"]#"zoom_choose_energy"] 


scheleton.plot(    
                    pyplot_merged_Param,
                    pyplot_pyjl_pairs,
                    pyplot_extra_sliders,
                    pyplot_init_sliders,
                    insets=insets)



#init_plot = scheleton.init_plot(
#                    pyplot_pyjl_pairs,
#                    pyplot_init_sliders,
#                    insets=insets 
#                    )

#    return figure, insets, nr_rc 
#

#out = scheleton.plot_direct_frominit(*init_plot,
#        record_data=True)


#
#out = scheleton.plot_frominit(
#        pyplot_merged_Param,
#        pyplot_pyjl_pairs,
#        *init_plot,
#        pyplot_extra_sliders,
#        pyplot_init_sliders
#        )





#fn = "jte.json"
#
##with open(fn,"w") as f: json.dump(out, f , cls=Utils.NumpyEncoder)
#
#
#
#
##print("len(out)=",len(out))   
#
#
##scheleton.plot_fromdata(**out) 
#
#out = scheleton.load_data(fn)
#
#i0 = scheleton.init_plot_0([out["components"]["2"] for i in range(5)])
#
#scheleton.plot_fromdata(**scheleton.data_from_plot0(i0))





#scheleton.plot_fromfile(fn)










