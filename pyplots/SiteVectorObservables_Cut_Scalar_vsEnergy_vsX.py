import numpy as np
import Plot
from SiteVectorObservables_Cut_Scalar_vsEnergy import plot as plot0
from SiteVectorObservables_Cut_Scalar_vsEnergy import add_sliders, read_sliders


def nr_axes(nrowcol=None, **kwargs):

    if nrowcol is None:

        return 1

    return np.prod(nrowcol)



def plot(Ax, get_plotdata, **kwargs):



    Data = get_plotdata(kwargs)

    Z = Data.pop("z")

    def title(c,a):
       
        return "=".join([Data[f"plot{c}label"], str(Data[f"plot{c}"][a])])

    fs = dict(filter(lambda it: it[0]=="fontsize", kwargs.items()))

    T = Data.get("suptitle", kwargs.get("suptitle", None))

    if T is not None:

        print(T)
#        Ax[0].get_figure().suptitle(T, **fs)



    for (i, ax) in zip(np.ndindex(*Z.shape[2:]), Ax):

        plot0([ax], lambda aux: {**Data, "z": Z[(...,*i)]}, **kwargs, show_colorbar=False)

        Plot.disable_labels(ax)


        ax.set_title(", ".join([title(*I) for I in zip("xy",i)]), **fs)



    
    
    
                
