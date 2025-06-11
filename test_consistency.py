from juliacall import Main as jl
import numpy as np
from relaxationColor import relaxationColorMap


if __name__ == "__main__":
    # config
    maptype = "T1"
    im = np.load('sampleT1map.npy')
    loLev = 400.0
    upLev = 2000.0

    # Julia 
    jl.include("RelaxationColor.jl")
    imClip_julia, cmap_julia = jl.relaxationColorMap(maptype, im, loLev, upLev)
    imClip_julia = np.asarray(imClip_julia)
    cmap_julia = np.asarray([[x.r, x.g, x.b] for x in cmap_julia])

    # Python
    imClip_python, cmap_python = relaxationColorMap(maptype, im, loLev, upLev)
    imClip_python = np.asarray(imClip_python)
    cmap_python = cmap_python.colors

    if np.allclose(imClip_julia, imClip_python):
        print("imClip match between Julia and Python")
    else:
        raise ValueError("imClip mismatch between Julia and Python")
    
    if np.allclose(cmap_julia, cmap_python):
        print("cmap match between Julia and Python")
    else:
        raise ValueError("cmap mismatch between Julia and Python")
