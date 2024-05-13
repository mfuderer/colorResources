function [xClip, lutCmap] = relaxationColorMap(maptype, x, loLev, upLev)
% [xClip, lutCmap] = relaxationColorMap(maptype, x, loLev, upLev)
%
% RelaxationColorMap: acts in two ways:
%   1. generate a colormap to be used on display, given image type 
%      (which must be one of 
%       "T1","R1","T2","T2*","R2","R2*","T1rho","T1ρ","R1rho","R1ρ","t1","r1","t2","t2*","r2","r2*","t1rho","t1ρ","r1rho","r1ρ")
%      and given the range of the image to be displayed;
%   2. generates a 'clipped' image, which is a copy of the input image except that values are clipped to the lower level,
%      while respecting the special value of 0 (which has to map to the "invalid" color)
% INPUTS:
%    maptype: a string from aformentioned series, e.g. "T1"  or "R2"
%    x      : ND array containing the image to be displayed
%    loLev  : lower level of the range to be displayed
%    upLev  : upper level of the range to be displayed
% OUTPUTS:  
%    xClip  : value-clipped image with the same size as x
%    lutCmap: 256 by 3 colormap to be used in image-display functions (in Colors.RGB format)
%
% Original version by M. Fuderer, UMC Utrecht; using ChatGPT on RelaxationColor.jl
% 3-4-2024, D.Poot, Erasmus MC: bugfixes and substantial performance improvement. 


    fn = fullfile(fileparts(mfilename('fullpath')));
    maptype(1) = upper(maptype(1));
    if ismember(maptype, {'T1', 'R1'})
        fn = fullfile(fn, 'lipari.csv');
    elseif ismember(maptype, {'T2', 'T2*', 'R2', 'R2*', 'T1rho', 'T1ρ', 'R1rho', 'R1ρ'})
        fn = fullfile(fn, 'navia.csv');
    else
        error('Expect ''T1'', ''T2'', ''R1'', or ''R2'' as maptype');
    end
    colortable = dlmread(fn, ' ', 0, 0);

    if maptype(1) == 'R'
        colortable = flipud(colortable);
    end

    colortable(1, :) = 0.0; % set 'invalid value' color. 

    % modification of the image to be displayed
    eps = (upLev - loLev) / size(colortable, 1);

    if loLev < 0
%         xClip = arrayfun(@(p) (p < eps) * (loLev - eps) + (p >= eps) * p, x);
        xClip = (x < eps) .* (loLev - eps) + (x >= eps) .* x;
        
    else
        xClip = (x <  eps) .* (loLev - eps) ...  
              + (x >= eps) .* ( (x < loLev + eps) .* (loLev + 1.5 *eps ) +  (x >= loLev + eps) .* x);
%   What happens here:  For each element in x individually:
%     if ~isfinite( x )        % to make explicit what happens to not-finite values
%        if x>0  % positive infinite only. 
%           xClip = inf
%        else 
%           xClip = nan
%     elseif (x< eps) 
%        xClip = loLev - eps   % maps to 'invalid' color. 
%     elseif (x< loLev + eps) 
%        xClip = loLev + eps   % maps to minimum valid color. 
%     else 
%        xClip = x;
%     end
    end
    lutCmap = colorLogRemap(colortable, loLev, upLev);
end