# Example script of using relaxationColor 

using PyPlot
using FileIO
include("RelaxationColor.jl")                   # the location of the julia files from git

fn = "sampleT1map.jld"          # A previously stored file containing the Julia variable "myT1",
                                                #  assumed to be a 2-dimensional (or 3-dimensional) array of Float
im = FileIO.load(fn)["sampleT1map"]

loLev = 400.0; upLev = 2000.0;                  # Example of range to be displayed
imClip, rgb_vec = relaxationColorMap("T1", im, loLev, upLev)  # call to resource, generating a colormap 
cmap = PyPlot.ColorMap("relaxationColor", rgb_vec, length(rgb_vec), 1.0) # translating the colormap to a format digestible by 
                                                                         #  (in this example) PyPlot                    

figure()
imshow(imClip, vmin=loLev, vmax =upLev, interpolation="bicubic", cmap=cmap)
colorbar()