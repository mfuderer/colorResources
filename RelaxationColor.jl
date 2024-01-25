using Colors
using DelimitedFiles

# RelaxationColorMap: acts in two ways:
#   1. generate a colormap to be used on display, given image type 
#      (which must be one of 
#       "T1","R1","T2","T2*","R2","R2*","T1rho","T1ρ","R1rho","R1ρ","t1","r1","t2","t2*","r2","r2*","t1rho","t1ρ","r1rho","r1ρ")
#      and given the range of the image to be displayed;
#   2. generates a 'clipped' image, which is a copy of the input image except that values are clipped to the lower level,
#      while respecting the special value of 0 (which has to map to the "invalid" color)
#   Arguments:
#       maptype: a string from aformentioned series, e.g. "T1"  or "R2"
#       x:       the image to be displayed
#       loLev       lower level of the range to be displayed
#       upLev       upper level of the range to be displayed
#   Returns:  
#       value-clipped image
#       colormap to be used in image-display functions (in Colors.RGB format)
function relaxationColorMap(maptype::String, x, loLev, upLev)
    fn = @__DIR__
    Maptype = uppercasefirst(maptype)
    if (Maptype in ["T1","R1"])
        fn = fn*"/lipari.csv"
    elseif (Maptype in ["T2","T2*","R2","R2*","T1rho","T1ρ","R1rho","R1ρ"])
        fn = fn*"/navia.csv"
    else
        fn = fn*"/"*maptype*".csv"
    end
    colortable = readdlm(fn, ' ', '\n')

    if Maptype[1]=='R'
        colortable = reverse(colortable,dims=1)
    end

    colortable[1,:] .= 0.0;

    # modification of the image to be displayed; this is needed because with e.g. a loLev of 100,
    #    the values of 1 ... 99 have to be displayed differently than 0 ("invalid")
    eps = (upLev-loLev)/size(colortable)[1]
    xClip = map(x) do p
        (p < eps) ? loLev-eps : ((p < loLev+eps) ? loLev+1.5*eps : p)  # the 1.5 anticipates a "floor" in the viewing pipeline
    end   
    if (loLev < 0)
        xClip = map(x) do p
            (p < eps) ? loLev-eps : p
        end 
    end                         

    lutCmap = colorLogRemap(colortable,loLev,upLev)
    rgb_vec = map(rgb -> Colors.RGB(rgb...), eachrow(lutCmap))
    return xClip, rgb_vec
end

# colorLogRemap: lookup of the original color map table according to a "log-like" curve.
#   The log-like curve contains a linear part and a logarithmic part; the size of the parts
#   depends on the range (loLev,upLev) 
#
#   Arguments:
#       oriCmap     original colormap, provided as a N*3 matrix
#       loLev       lower level of the range to be displayed
#       upLev       upper level of the range to be displayed
#   Returns:  modified colormap
function colorLogRemap(oriCmap, loLev=0.0, upLev=size(cmap)[1])
    @assert (upLev>0) "upper level must be positive"
    @assert (upLev>loLev) "upper level must be larger than lower level"
    logCmap = similar(oriCmap)
    mapLength = size(oriCmap)[1]
    eInv = exp(-1.0)
    aVal = eInv*upLev
    mVal = max(aVal,loLev)
    bVal = (aVal < loLev) ? (1.0 / mapLength) : (aVal-loLev)/(2*aVal-loLev)+(1.0 / mapLength)
    bVal += 0.0000001   # This is to ensure that after some math, we get a figure that rounds to 1 ("darkest valid color")
                        # rather than to 0 (invalid color). Note that bVal has no units, so 1E-7 is always a small number
    logCmap[1,:] = oriCmap[1,:] # the 'invalid' color
    logPortion = 1.0/(log(mVal)-log(upLev))

    for g in 2:mapLength
        f = 0.0
        x = g*(upLev-loLev)/mapLength+loLev
        if x > mVal
            # logarithmic segment of the curve
            f = mapLength*((log(mVal)-log(x))*logPortion*(1-bVal)+bVal)
        else
            if (loLev < aVal)&&(x>loLev)
                # linear segment of the curve
                f = mapLength*((x-loLev)/(aVal-loLev)*(bVal-(1.0 / mapLength)))+1.0
            end
            if (x<=loLev) 
                # lowest valid color
                f = 1.0
            end
        end
        # lookup from original color map
        logCmap[g,:] = oriCmap[min(mapLength,1+floor(Int64,f)),:]
    end
    return logCmap
end
