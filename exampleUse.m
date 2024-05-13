% Load the matlab file containing an example T1 map 
fn = 'sampleT1map.mat';
data = load(fn);
im = data.sampleT1;

loLev = 400.0;
upLev = 2000.0;

% Call the relaxationColorMap function
% This (slightly) processes im into imClip, by setting all values 0<x<loLev to loLev+eps, and all values x>=loLev to x.
% It also returns the log-processed Lipari map for 'T1' and the log-processed Navia map for 'T2'
% (If im is a T2 map, use 'T2' instead of 'T1')
[imClip, rgb_vec] = relaxationColorMap('T1', im, loLev, upLev);

% Display the image using MATLAB
figure;
imshow(imClip, 'DisplayRange', [loLev, upLev], 'InitialMagnification', 'fit');
colormap(rgb_vec);
colorbar;