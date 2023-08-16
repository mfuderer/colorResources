% Load necessary matlab modules
addpath('/my/git/location');  


% Load the Julia file containing the variable "myT1"
fn = '/my/T1/file/loction/T1image.mat';
data = load(fn);
im = data.myT1;

loLev = 400.0;
upLev = 2000.0;

% Call the relaxationColorMap function
[imClip, rgb_vec] = relaxationColorMap('T1', im, loLev, upLev);

% Display the image using MATLAB
figure;
imshow(imClip, 'DisplayRange', [loLev, upLev], 'InitialMagnification', 'fit');
colormap(rgb_vec);
colorbar;