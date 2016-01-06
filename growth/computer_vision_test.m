% this cell is solely for testing purposes

%%
I = imread('circuit.tif');
corners = detectFASTFeatures(I,'MinContrast',0.05);
J = insertMarker(I,corners,'circle');
imshow(J);

%%
original = imread('cameraman.tif');
figure;
imshow(original);
%%
scale = 1.3;
J = imresize(original,scale);
theta = 31;
distorted = imrotate(J,theta);
figure
imshow(distorted)

%%

ptsOriginal  = detectSURFFeatures(original);

[featuresOriginal,validPtsOriginal]  = extractFeatures(original,ptsOriginal);

  figure; imagesc(original); hold on
plot(validPtsOriginal)
%%

threshold=single(0.99);
level=2;
hVideoSrc=vision.VideoFileReader('vipboard.avi',...
    'VideoOutputDataType','Single',...
    'ImageColorSpace','Intensity');
hGaussPymd1 = vision.Pyramid('PyramidLevel',level);
hGaussPymd2 = vision.Pyramid('PyramidLevel',level);
hGaussPymd3 = vision.Pyramid('PyramidLevel',level);
hRotate1=vision.GeometricRotator('Angle',pi);

hFFT2D1=vision.FFT;
hFFT2D2=vision.FFT;
hIFFT2D=vision.IFFT;
hConv2D=vision.Convolver('OutputSize','Valid');

%%
% Specify the target image and number of similar targets to be tracked. By
% default, the example uses a predefined target and finds up to 2 similar
% patterns. Set the variable useDefaultTarget to false to specify a new
% target and the number of similar targets to match.
useDefaultTarget = true;
[Img, numberOfTargets, target_image] = ...
  videopattern_gettemplate(useDefaultTarget);

%%
% Downsample the target image by a predefined factor using the
% gaussian pyramid System object. You do this to reduce the amount of
% computation for cross correlation.
target_image = single(target_image);
target_dim_nopyramid = size(target_image);
target_image_gp = step(hGaussPymd1, target_image);
target_energy = sqrt(sum(target_image_gp(:).^2));

%%

% Rotate the target image by 180 degrees, and perform zero padding so that
% the dimensions of both the target and the input image are the same.
target_image_rot = step(hRotate1, target_image_gp);
[rt, ct] = size(target_image_rot);
Img = single(Img);
Img = step(hGaussPymd2, Img);
[ri, ci]= size(Img);
r_mod = 2^nextpow2(rt + ri);
c_mod = 2^nextpow2(ct + ci);
target_image_p = [target_image_rot zeros(rt, c_mod-ct)];
target_image_p = [target_image_p; zeros(r_mod-rt, c_mod)];

% Compute the 2-D FFT of the target image
target_fft = step(hFFT2D1, target_image_p);

% Initialize constant variables used in the processing loop.
target_size = repmat(target_dim_nopyramid, [numberOfTargets, 1]);
gain = 2^(level);
Im_p = zeros(r_mod, c_mod, 'single'); % Used for zero padding
C_ones = ones(rt, ct, 'single');      % Used to calculate mean using conv