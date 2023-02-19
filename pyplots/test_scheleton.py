import numpy as np  

import scheleton  
import test_vectorfield, test_scatter 

pyplot_merged_Param = (["a","b","c"], 
                        [[0,1,2], np.linspace(0,3,100), ["c1","c2"]]
                        )


pyplot_pyjl_pairs = [["Scatter",test_scatter.get_plotdata,"test1"],
                        ["VectorField", test_vectorfield.get_plotdata, "test2"]]

pyplot_init_sliders = {"enlim":[-1,2]} 

pyplot_extra_sliders = ["choose_k"]#"zoom_choose_energy"] 


scheleton.plot(pyplot_merged_Param,
                    pyplot_pyjl_pairs,
                    pyplot_extra_sliders,
                    pyplot_init_sliders)




