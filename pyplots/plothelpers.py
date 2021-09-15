import numpy as np
import warnings  
import Plot,Utils,Algebra

def inset_sizes(rectangle, kwargs):

    return Plot.inset_sizes(rectangle, kwargs, 
            ["fontsize", "dotsize", "atomsize", "arrow_scale", "linewidth"])


#def generate_combs(N=None, *args):
#
#    allcombs = np.array(list(np.ndindex(*(len(a) for a in args))))
#        
#    Nt = len(allcombs)
#
#    left_combs = np.ones(Nt, bool)
#
#    nr_used = [np.zeros(len(a),int) for (i,a) in enumerate(args)]
#
## number of times the ni-th element of the list args[i] has been used
#
#
#    for j in range(Nt if N is None else min(N,Nt)):
#
#                    #left_combs = np.ones(Nt, bool)
##                    nr_used = [np.zeros(len(a),int) for (i,a) in enumerate(args)]
#
#        #    raise error("Cannot produce so many unique combinations")
#
#        cost = np.zeros(Nt, float)
#
#        for (i,(available,comb)) in enumerate(zip(left_combs,allcombs)):
#
#            if not available: 
#                
#                cost[i] = len(args)
#
#            else:
#
#                for (nr,c) in zip(nr_used, comb):
#    
#                    u = list(np.unique(nr))
#
#                    cost[i] += u.index(nr[c])/len(u)
#
#        i0 = np.argmin(cost)
#
#        left_combs[i0] = False 
#
#        comb = allcombs[i0]
#        
#        for (i,ni) in enumerate(comb):
#            nr_used[i][ni] +=1 
#
#
#
#
#
#
#        yield tuple([a[c] for (a,c) in zip(args,comb)])
#


linestyles=['-',':','--','-.']
#linemarkers=["","o","X"]


#def linekwargs(N=None):
#
#    for (ls,m) in generate_combs(N, linestyles,linemarkers):
#
#        yield {'linestyle':ls,'marker':m}




#colors = ["b","r","g","orange","k","y"]

colors = np.roll([["brown","red","coral","peru"],["gold","olive","forestgreen","lightseagreen"],["dodgerblue","midnightblue","darkviolet","deeppink"]],1,axis=1).T.reshape(-1)


#def clslw(D):
#
#  n = len(D)
#
#  for (c,ls,lw) in zip(colors,linestyles,np.linspace(3,2,n)):
#
#    yield {"color":c,"linestyle":ls,"linewidth":lw}
#




def nrowscols(n, nrowcol=None, **kwargs):

    if nrowcol is None:

        #  return (int(np.ceil(n/2)),2)  # screen in portrait mode
        
        if n <= 3: return (1,n)
          
        if n <= 8: return (2,int(np.ceil(n/2)))
        
        return (3,int(np.ceil(n/3)))
    
    ncols = nrowcol[1]

    return (int(np.ceil(n/ncols)), ncols)











def get_one_or_many(data):

    def d(c):
    
        if data.get(c, None) is not None:
                
            return [data[c]]
   
        if data.get(c+"s", None) is not None:

            return data[c+"s"]

        return None

    return d



def is_single_element(p):


    if isinstance(p,(np.ndarray,list)):
        if np.size(p) > 1:
            return False

    return True

def get_single_element(val):


    if isinstance(val,(np.ndarray,list)):
        if np.size(val) == 1:
            return val[0]

    return val


def get_single_elements(params):

    out = {}

    rem_inds = []

    for (i,(k,v)) in enumerate(zip(*params)):

        if is_single_element(v):

            out[k] = get_single_element(v)

            rem_inds.append(i)

    return [[p for (i,p) in enumerate(P) if i not in rem_inds] for P in params],out


def printable_string(S):

    parts = [s for s in S.split("_") if len(s)]

    parts[0] = parts[0][0].upper() + parts[0][1:]

    return " ".join(parts)


def get_paramsplot(obj,libraries):

    param_plot = libraries[0][0].read_sliders(obj)
    
    for (lib,f,t) in libraries[1:]:
    
        param_plot.update(lib.read_sliders(obj))

    return param_plot


def combobox_or_slider(values):

    if np.size(values) < 5:
   
        return "combobox"

    else:
        
        return "slider"

def key_widget(i, name):

    return name
#    return "p"+str(i)


def add_widget(fig, i, name, values):


    kwargs = {  "label": printable_string(name),
                "key" : key_widget(i, name),
                "vs" : values
                }


    if combobox_or_slider(values) == "combobox":

        fig.add_combobox(**kwargs)

    else:

        fig.add_slider(**kwargs, columnSpan=5+i%2)


def get_widget(obj, i, name, values):

    if combobox_or_slider(values)=="combobox":

        out = obj.get_combobox(key_widget(i, name))

    else:

        out = obj.get_slider(key_widget(i, name))


    with warnings.catch_warnings():  
        warnings.filterwarnings("ignore",category=FutureWarning)

        if out=="True":
            return True
    
        if out=="False":
            return False
    
    return type(values[0])(out)

def get_paramsuser(obj,params):

    return {n:get_widget(obj,i,n,p) for (i,(n,p)) in enumerate(zip(*params))}



def getlim(dat,f=lambda u:u):


    if dat is None: 
        
        return [None,None]

    if isinstance(dat, float) or isinstance(dat, int):
        return [dat,dat] 

    for d in dat:
        if d is None:
            return [None,None]


    if isinstance(dat, np.ndarray):

        return Algebra.minmax(f(dat))

    return Algebra.minmax([Algebra.minmax(f(di)) for di in dat])



def deduce_axislimits(data=None, limits=None):

    data = Utils.Assign_Value(data, [None,None])

    limits = Utils.Assign_Value(limits, np.repeat(None,len(data))) 

    limits = [Utils.Assign_Value(lim, [None,None]) for lim in limits]


    if len(data)==3 and len(limits)==3:

        xlim, ylim = deduce_axislimits(data[0:2], limits[0:2])

        zlim = []

        for (l1, l2) in zip(limits[2], getlim(data[2])):

            zlim.append(l2 if l1 is None else l1)

        return xlim,ylim,zlim



    if len(data)!=2 or len(limits)!=2:

        raise

    
    limits_given = [False, False]
    
    for i,lim in enumerate(limits): 

        if lim is not None and len(lim)==2:
            
            if all([isinstance(l,int) or isinstance(l,float) for l in lim]):
            
                limits_given[i] = True 


    nr_lim = sum(limits_given)



    if nr_lim==2:

        return limits 


    elif nr_lim==0:

        return [Plot.extend_limits(getlim(d)) for d in data]


    else:

        g, ng = np.argmax(limits_given), np.argmin(limits_given)
    
    
        def restrict(item):
    
            v,w = [np.array(i) for i in item]
          
            if v is None or w is None:
                return None 

            if None in v or None in w:
                return None 



            return w[np.logical_and(v>=limits[g][0], v<=limits[g][1])] 
    


        limits[ng] = getlim(list(zip(data[g],data[ng])), restrict)
  
        return limits 
   







def plot_levellines(ax, get_line, **kwargs):

    xylim = [ax.get_xlim(), ax.get_ylim()]


    for (i,c) in enumerate("xy"):

        line = get_line(c+"line")

        if line is not None:
    
            xy = xylim.copy()
    
            xy[i] = [line,line]
    
            ax.plot(*xy, **kwargs)
    
    
    for (l,f) in zip(xylim, [ax.set_xlim, ax.set_ylim]):
    
        f(l)
    
    

def set_xylabels(ax, get_label, **kwargs):

    for (c,f) in zip("xy", (ax.set_xlabel, ax.set_ylabel) ):

        label = get_label(c+"label")

        if label is not None:

            f(label, **kwargs)
            


#def update_vminmax(imposed_min, imposed_max, actual_min, actual_max):
#def update_vminmax(imposed_minmax, actual_minmax):
#
#                            # if it exists and makes sense
#
#    imposed_min,imposed_max = Utils.Assign_Value(imposed_minmax, [None,None])
#
#    actual_min,actual_max = Utils.Assign_Value(actual_minmax, [None,None])
#
#    if imposed_min is not None:
#
#        if actual_max is None or imposed_min < actual_max:
#                
#            actual_min = imposed_min
#            
#    if imposed_max is not None:
#        
#        if actual_min is None or imposed_max > actual_min:
#            
#            actual_max = imposed_max 
#
#            
#    return actual_min, actual_max
#


#
