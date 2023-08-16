function [xClip, lutCmap] = relaxationColorMap(maptype, x, loLev, upLev)
    fn = fullfile(fileparts(mfilename('fullpath')));
    mmm = char(maptype);
    mmm(1) = upper(mmm(1));
    if ismember(mmm, {'T1', 'R1'})
        fn = fullfile(fn, 'lipari.csv');
    elseif ismember(mmm, {'T2', 'T2*', 'R2', 'R2*', 'T1rho', 'T1ρ', 'R1rho', 'R1ρ'})
        fn = fullfile(fn, 'navia.csv');
    else
        error('Expect ''T1'', ''T2'', ''R1'', or ''R2'' as maptype');
    end
    colortable = dlmread(fn, ' ', 1, 0);

    if mmm(1) == 'R'
        colortable = flipud(colortable);
    end

    colortable(1, :) = 0.0;

    % modification of the image to be displayed
    eps = (upLev - loLev) / size(colortable, 1);
    xClip = arrayfun(@(p) (p < eps) * (p < loLev + eps) * (loLev - eps) + ...
                    (p < eps) * (p >= loLev + eps) * (loLev + eps) + (p >= eps) * p, x);

    if loLev < 0
        xClip = arrayfun(@(p) (p < eps) * (loLev - eps) + (p >= eps) * p, x);
    end

    lutCmap = colorLogRemap(colortable, loLev, upLev);
end
