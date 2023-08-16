% colorLogRemap: lookup of the original color map table according to a "log-like" curve.
%   The log-like curve contains a linear part and a logarithmic part; the size of the parts
%   depends on the range (loLev,upLev) 
%
%   Arguments:
%       oriCmap     original colormap, provided as a N*3 matrix
%       loLev       lower level of the range to be displayed
%       upLev       upper level of the range to be displayed
%   Returns:  modified colormap
function logCmap = colorLogRemap(oriCmap, loLev, upLev)
    assert(upLev > 0, 'upper level must be positive');
    assert(upLev > loLev, 'upper level must be larger than lower level');
    
    mapLength = size(oriCmap, 1);
    eInv = exp(-1.0);
    aVal = eInv * upLev;
    mVal = max(aVal, loLev);
    bVal = (1.0 / mapLength) + (aVal >= loLev) * ((aVal - loLev) / (2 * aVal - loLev));
    bVal = bVal+0.0000001;   % This is to ensure that after some math, we get a figure that rounds to 1 ("darkest valid color")
                        % rather than to 0 (invalid color). Note that bVal has no units, so 1E-7 is always a small number    
    logCmap = zeros(size(oriCmap));
    logCmap(1, :) = oriCmap(1, :);
    
    logPortion = 1.0 / (log(mVal) - log(upLev));

    for g = 2:mapLength
        f = 0.0;
        x = g * (upLev - loLev) / mapLength + loLev;
        
        if x > mVal
            % logarithmic segment of the curve
            f = mapLength * ((log(mVal) - log(x)) * logPortion * (1 - bVal) + bVal);
        else
            if (loLev < aVal) && (x > loLev)
                % linear segment of the curve
                f = mapLength * ((x - loLev) / (aVal - loLev) * (bVal - (1.0 / mapLength))) + 1.0;
            end
            
            if (x <= loLev) 
                % lowest valid color
                f = 1.0;
            end
        end
        
        % lookup from original color map
        logCmap(g, :) = oriCmap(min(mapLength, 1 + floor(f)), :);
    end
    
    % Return modified colormap
end
