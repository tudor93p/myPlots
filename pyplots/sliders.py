from plothelpers import *
import itertools
import Plot


def addread_sliders(*slider_set):

    slider_functions = [s() for s in slider_set]
   
    add_font,read_font = fontsizes()

    def add_(fig, **kwargs):
      
        for (add,read) in slider_functions:
    
            add(fig, **kwargs) 

            add_font(fig, **kwargs) 
    
    def read_(obj):
    
        out = read_font(obj)

#        out = slider_functions[0][1](obj)
        
        for (add,read) in slider_functions:#[1:]:
    
            out.update(read(obj))
    
        return out


    return add_,read_


#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#


def islocal(O):
    return "Local" in O


def isbondvector(O):
    return "BondVector" in O

def issitevector(O):
    return "SiteVector" in O


def isobs(O):

    for f in [isbondvector, islocal, issitevector]:

        if f(O): return False

    return True




#===========================================================================#
#
# Choose an energy lavel -- convolute observables
#
#---------------------------------------------------------------------------#

def zoom_choose_energy():

    def add(fig, enlim=None, **kwargs):
   
        
#        fig.add_text(label="Center energy", key="shift", text="")

        if enlim is not None:
    
#            fig.add_slider(label="Center energy", key="shift", columnSpan=4,
#                    vs = np.linspace(*enlim,51), v0 = 25)

            fig.add_slider(label="Zoom energy", key="zoom", columnSpan=5,
                    vs=np.linspace(1,0,80)*(np.max(enlim) - np.mean(enlim))
                    )
        
            fig.add_slider(label="Energy", key="sEnergy", vs=np.linspace(0,1,61), columnSpan=4, v0=30)


        fig.add_text(label="Energy",key="Energy",text="")


        fig.add_text(label="Window E",key="sample_states_width_E",text="")
    
        fig.add_combobox(["Lorentzian","Gaussian","Rectangle"],label="Sample method",key="sample_states_method")




    def get_en(obj, enlim=None):
        
        try: 
            return float(obj.get_text("Energy"))

        except:

            try:

                m,M = enlim 

                return m + (M-m)*obj.get_slider("sEnergy")

#                obj.set_text("Energy", Energy)

            except:

                return 0.0


    def read(obj):
   
        shift = read_text(obj, "shift").get("shift", 0)
        
        try: 
            enlim = np.array([-1,1])*obj.get_slider("zoom") + shift
        
        except:

            enlim = None
        
        try: delta = float(obj.get_text("sample_states_width_E"))

        except: delta = 0.02
    
        return {"enlim" : enlim,
                "Energy" : get_en(obj, enlim),
                "E_width" : delta,
                "interp_method" : obj.get_combobox("sample_states_method")
                }
    
    
    return add,read
    




#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#


def choose_k():

    def add(fig, **kwargs):
   
        fig.add_text(label="Eigenvalue index",key="kpoint",text="")

        fig.add_text(label="Window k",key="sample_states_width_k",text="")
    
        fig.add_combobox(["Lorentzian","Gaussian","Rectangle"],
                    label="Sample states method",key="sample_states_method")
    
        fig.add_slider(label="Zoom k", key="zoomk", columnSpan=4,
                    vs=np.linspace(1,0,80,endpoint=False))
    
    def read(obj):
   
        out = read_slider(obj, "zoomk")

        out["k_width"] = 0.02 

        out.update(read_text(obj, "sample_states_width_k", "k_width")) 


        out["interp_method"] = obj.get_combobox("sample_states_method")

        out.update(read_text(obj, "kpoint", "k"))

        return out 

    
    return add,read




#===========================================================================#
#
# operators
#
#---------------------------------------------------------------------------#


def operators():

    
    def add(fig, HOperNames=[], **kwargs):

        fig.add_combobox([O for O in HOperNames if isobs(O)],
                                                label="Operator",key="oper")
      
    def read(obj):
    
        return read_combobox(obj, "oper")


    return add,read


#===========================================================================#
#
#  observable  
#
#---------------------------------------------------------------------------#

def observables():
    
    def add(fig, ObsNames=[], **kwargs):
      
        fig.add_combobox([O for O in ObsNames if isobs(O)],
                            label="Observable", key="obs")
    
    def read(obj):
   
        return read_combobox(obj, "obs")


    return add,read






def obs_index():

    def add(fig, **kwargs):

        fig.add_combobox(range(1,10),label="Observable i",key="obs_i")
        
    def read(obj):

        return read_combobox(obj, "obs_i", int)


    return add,read
   



#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#



def partial_observables():
    
    def add(fig, PartialObs=[], **kwargs):
      
        fig.add_combobox(PartialObs,
                            label="Partial observable", key="partobs")
    
    def read(obj):
    
        return read_combobox(obj, "partobs")

    return add,read


def regions():

    def add(fig, Regions=None, **kwargs):

        if Regions is not None:

            fig.add_combobox(range(1,Regions+1), 
                                    label="Region", key="region")


    def read(obj):

        return read_combobox(obj, "region", int)


    return add,read

#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#




def bondvector_observables():

    def add(fig, BondVectorObsNames=[], **kwargs):
    
        obs = [O for O in BondVectorObsNames if isbondvector(O)]
      
        fig.add_combobox(obs, key="bondvectorobs",
                            label="Bond vector obs." if len(obs)>0 else "")

    def read(obj):
    
        return read_combobox(obj, "bondvectorobs")

    return add,read


def sitevector_observables():

    def add(fig, SiteVectorObsNames=[], **kwargs):
    
        obs = [O for O in SiteVectorObsNames if issitevector(O)]
      
        fig.add_combobox(obs, key="sitevectorobs",
                            label="Site vector obs." if len(obs)>0 else "")

    def read(obj):
    
        return read_combobox(obj, "sitevectorobs")

    return add,read

#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#

def sitevectorobs_vminmax():

    mM_svo = ["sitevectorobsmin", "sitevectorobsmax"]


    def add(fig, **kwargs):

#        for (mM,k) in zip(["Min","Max"],mM_svo):

#            fig.add_text(label=mM+" site vect.obs", key=k, text="")

        fig.add_text(label="Limits site vect.obs", key=mM_svo[0], text="")
        fig.add_text(key=mM_svo[1], text="")

    def read(obj):

        return read_many(lambda k: read_text(obj, k), mM_svo)


    return add,read



#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#

def read_checkbox(obj, key, key2=None):

    try:

        val = obj.get_checkbox(key)

        k = key if key2 is None else key2 

        return {k:val}

    except:

        return {}


def read_slider(obj, key):

    try:

        val = obj.get_slider(key)
        
        return {key: val}
#        k = key if dict_key is None else dict_key

 #       return {k: val if f is None else f(val)}
    
    except:
    
        return {}
    

    
def read_combobox(obj, key, f=None, dict_key=None):

    try:

        val = obj.get_combobox(key)

        k = key if dict_key is None else dict_key

        return {k: val if f is None else f(val)}
    
    except:
    
        return {}
    

def read_text(obj, key, dict_key=None):#, f=None):

    try:

        k = key if dict_key is None else dict_key

        return {k: float(obj.get_text(key))}
            
    except:
    
        return {}



def read_many(method, keys):


    out = {}

    for k in keys:

        D = method(k)

        if type(D)==dict:
            out.update(D)
        else:
            out[k]=D


    return out



#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#



def vec2scalar():

    def add(fig, Vec2Scalar=[], **kwargs):

        if len(Vec2Scalar):

            fig.add_combobox(Vec2Scalar, key="vec2scalar",
                                            label="Vector to scalar")

    def read(obj):

        return read_combobox(obj, "vec2scalar")

    return add,read




#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#





def transforms():

    def add(fig, Transforms=[], **kwargs):

        if len(Transforms):


            fig.add_combobox(Transforms, key="transform",
                                            label="Apply transform")

            fig.add_text(text="", key="transfparam", 
                                            label="Transf.param.")


    def read(obj):

        return {**read_combobox(obj, "transform"),
                **read_text(obj, "transfparam")
                }

    return add,read



#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#


def saturation():


    def add(fig, **kwargs):

        fig.add_slider(label="Saturation", key="saturation", columnSpan=4,
                    vs=np.linspace(0,1,80),v0=79)


    def read(obj):

        return read_slider(obj, "saturation")


    return add, read 


#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#



def local_observables():

    
    def add(fig, LocalObsNames=[], **kwargs):
    
        LocalObs = [O for O in LocalObsNames if islocal(O)]
        
        if len(LocalObs):

            fig.add_combobox(LocalObs, key="localobs",
                            label="Local obs." if len(LocalObs)>0 else "")

    
    
    def read(obj):
  
        return read_combobox(obj, "localobs")

    return add,read



#===========================================================================#
#
# min max values for observables/operators
#
#---------------------------------------------------------------------------#

def oper_vminmax():


    def add(fig, **kwargs):
    
        fig.add_text(label="Limits oper.",key="opermin",text="") 

        fig.add_text(key="opermax",text="") 

        fig.add_checkbox("Filter states", key="filterstates", status=False)

#        fig.add_text(label="Max val oper",key="opermax",text="")
    
    
    def read(obj):
    
        d = read_many(lambda k: read_text(obj, k), ["opermin", "opermax"])

        d.update(read_checkbox(obj, "filterstates"))

        return d


    return add,read



def obs_vminmax():


    def add(fig, **kwargs):
    
        fig.add_text(label="Limits obs",key="obsmin",text="")
    
        fig.add_text(key="obsmax",text="")
        #fig.add_text(label="Max.val.obs",key="obsmax",text="")
    
    
    def read(obj):
   
        return read_many(lambda k: read_text(obj, k), ["obsmin", "obsmax"])
    

    return add,read



#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#



def obs_group():

    def add(fig, **kwargs):
   
        fig.add_combobox(["-","Prefix","Name"],
                            label="Group", key="obs_group")

    def read(obj):
        
        return read_combobox(obj, "obs_group")


    return add,read


#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#

def partobs_vminmax():

    def add(fig, **kwargs):

        fig.add_text(label="Limits part.obs",key="pobsmin",text="")

#        fig.add_text(label="Max.val.part.obs",key="pobsmax",text="")
        fig.add_text(key="pobsmax",text="")

    def read(obj):

        return read_many(lambda k: read_text(obj, k), ["pobsmin","pobsmax"])


    return add,read

#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#

def localobs_vminmax():

    def add(fig, **kwargs):

        fig.add_text(label="Limits local obs", key="lobsmin", text="")

        fig.add_text(key="lobsmax", text="")

#        fig.add_text(label="Max val local obs",key="lobsmax",text="")

    def read(obj):

        return read_many(lambda k: read_text(obj, k), ["lobsmin","lobsmax"])


    return add,read

#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#


def colormap():

    def add(fig, **kwargs):

        fig.add_combobox(["cool",
                "PuBuGn","YlGnBu","copper",
                "plasma","coolwarm","Spectral","viridis",
                "twilight","hsv"
                ],label="Color map",key="cmap")

    def read(obj):
        
        return read_combobox(obj, "cmap")
    



    return add,read





#===========================================================================#
#
#   energy Zoom
#
#---------------------------------------------------------------------------#

energy_zoom = choose_energy = zoom_choose_energy
#
#    def add(fig, enlim=None, **kwargs):
#
#        if enlim is not None:
#    
#            fig.add_slider(label="Zoom energy", key="zoom", columnSpan=5,
#                    vs=np.linspace(1,0,80)*(np.max(enlim) - np.mean(enlim))
#                    )
#        
#            fig.add_slider(label="Center energy", key="shift", columnSpan=2,
#                    vs = np.linspace(*enlim,31), v0 = 15)
#    
#    def read(obj):
#    
#        return {"enlim": np.array([-1,1])*obj.get_slider("zoom") 
#                                            + obj.get_slider("shift")}
#   
#
#    return add,read



#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#

def smoothen():

    def add(fig, **kwargs):

       fig.add_slider(label="Smooth", key="smooth", 
               vs=np.linspace(0,1,40), columnSpan=3)

    def read(obj):
        return {"smooth" : obj.get_slider("smooth")}

    return add,read



def dotsizes():

    def add(fig, **kwargs):


       fig.add_slider(label="Dot size", key="dotsize", 
               vs=np.linspace(1,40,40), columnSpan=3, v0=5)


    def read(obj):

        return {"dotsize" : obj.get_slider("dotsize")}

    return add,read




def atomsizes():

    def add(fig, **kwargs):


       fig.add_slider(label="Atom size", key="atomsize", 
               vs=np.linspace(0.5,15,50)**2, columnSpan=3, v0=20)


    def read(obj):
        return {"atomsize" : obj.get_slider("atomsize")}

    return add,read




#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#

def arrow_parameters():

    mM = ["vectormin", "vectormax"]
    def add(fig, **kwargs):

        vs = np.linspace(0.001,0.2,40)/10

#        fig.add_slider(label="Arrow width", key="arrow_width",
#                            vs=vs, columnSpan=3)
#
#        fig.add_slider(label="Arrow head width", key="arrow_headwidth",
#                            vs=vs*3, columnSpan=3)
#

        fig.add_text(label="Limits vector field", key=mM[0], text="")
        fig.add_text(key=mM[1], text="")

#
#        fig.add_slider(label="Arrow head length", key="arrow_headlength",
#                            vs=vs*3*1.5, columnSpan=3)
#
#        fig.add_slider(label="Arrow max. len.", key="arrow_maxlength",
#                            vs=np.logspace(np.log10(0.01),np.log10(1),41),
#                            columnSpan=3, v0=40)




        fig.add_slider(label="Arrow scale", key="arrow_scale",
                            vs=np.concatenate((
                                np.linspace(0.01, 1, 50, endpoint=False),
                                np.linspace(1, 2, 15))),
                            columnSpan=4, v0=50)

        fig.add_slider(label="Arrow min. len.", key="arrow_minlength",
                            vs=np.append(0,np.logspace(np.log10(1e-3),np.log10(0.5),50)),
                            columnSpan=3, v0=0)

        fig.add_slider(label="Arrow uniform len.", key="arrow_uniformsize",
                            vs=np.linspace(0,1,40,endpoint=False), columnSpan=3)


        


    def read(obj):


        out = read_many(lambda k:obj.get_slider(k), 
                    ["arrow_scale", "arrow_minlength", "arrow_uniformsize",
#                    "arrow_width", "arrow_headwidth", "arrow_headlength",
#                    "arrow_maxlength"
                    ])

        out.update(read_many(lambda k: read_text(obj, k), mM))

        return out

    return add,read

#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#

def linewidths():

    def add(fig, **kwargs):

        fig.add_slider(label="Line width", key="lw", vs=np.linspace(0,4,40), columnSpan=3,v0=10)


    def read(obj):

        return {"linewidth" : obj.get_slider("lw")}

    return add,read


def fontsizes():

    def add(fig, **kwargs):

        fig.add_slider(label="Font size", key="fontsize", vs=np.linspace(7,20,20), columnSpan=2,v0=7)
        pass

    def read(obj):

        try:
            return {"fontsize" : obj.get_slider("fontsize")}
        except:
            return {"fontsize" : 10}



    return add,read







#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#

def insets():

    def add(fig, **kwargs):


        fig.add_combobox(Plot.inset_positions(),
                label="Inset location", key="inset_location")

        fig.add_slider(label="Inset size", key="inset_size", 
                columnSpan=4, vs = np.linspace(0.1,0.5,30), v0=10)

    def read(obj):

        return Plot.inset_positions(obj.get_combobox("inset_location"),
                                    obj.get_slider("inset_size"))




    return add,read

#===========================================================================#
#
#
#
#---------------------------------------------------------------------------#


def pick_systems():
    
    
    def add(fig, more_systems=None, **kwargs):

        if more_systems is not None and len(more_systems)>1:
    
            vals = []
    
            for n in range(len(more_systems)):

                for item in itertools.combinations(more_systems,n+1):
    
                    vals.append(" ".join(item))
    
            fig.add_combobox(vals, label="Systems", key="systlabel")
                

    def read(obj):

        return read_combobox(obj, "systlabel")



    return add,read



































