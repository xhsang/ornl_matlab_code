% learn from the cell counting example
%%
VideoSize = [432 528];

%%
filename = 'ecolicells.avi';
hvfr = vision.VideoFileReader(filename, ...
    'ImageColorSpace', 'Intensity',...
    'VideoOutputDataType', 'single');

%%
hautoth = vision.Autothresholder( ...
    'Operator', '<=', ...
    'ThresholdScaleFactor', 0.8);

%%
hblob = vision.BlobAnalysis( ...
    'AreaOutputPort', false, ...
    'BoundingBoxOutputPort', false, ...
    'OutputDataType', 'single', ...
    'MinimumBlobArea', 7, ...
    'MaximumBlobArea', 300, ...
    'MaximumCount', 1500);

% Acknowledgement
ackText = ['Data set courtesy of Jonathan Young and Michael Elowitz, ' ...
    'California Institute of Technology'];

%%
hVideo = vision.VideoPlayer;
hVideo.Name  = 'Results';
hVideo.Position(1) = round(hVideo.Position(1));
hVideo.Position(2) = round(hVideo.Position(2));
hVideo.Position([4 3]) = 30+VideoSize;

%%
frameCount = int16(1);
while ~isDone(hvfr)
    % Read input video frame
    image = step(hvfr);

    % Apply a combination of morphological dilation and image arithmetic
    % operations to remove uneven illumination and to emphasize the
    % boundaries between the cells.
    y1 = 2*image - imdilate(image, strel('square',7));
    y1(y1<0) = 0;
    y1(y1>1) = 1;
    y2 = imdilate(y1, strel('square',7)) - y1;

    y3 = step(hautoth, y2);       % Binarize the image.
    Centroid = step(hblob, y3);   % Calculate the centroid
    numBlobs = size(Centroid,1);  % and number of cells.
    % Display the number of frames and cells.
    frameBlobTxt = sprintf('Frame %d, Count %d', frameCount, numBlobs);
    image = insertText(image, [1 1], frameBlobTxt, ...
            'FontSize', 16, 'BoxOpacity', 0, 'TextColor', 'white');
    image = insertText(image, [1 size(image,1)], ackText, ...
            'FontSize', 10, 'AnchorPoint', 'LeftBottom', ...
            'BoxOpacity', 0, 'TextColor', 'white');

    % Display video
    image_out = insertMarker(image, Centroid, '*', 'Color', 'green');
    step(hVideo, image_out);

    frameCount = frameCount + 1;
end

release(hvfr); % close the video file

%% now let us analyze this crap in details

image_dilated=imdilate(image, strel('square',7));;
imshowpair(image,image_dilated,'montage');

%%
y1 = 2*image - imdilate(image, strel('square',7));
imagesc(y1);

%%
    I(y1<0) = 0;
    y1(y1>1) = 1;
    y2 = imdilate(y1, strel('square',7)) - y1;
    imagesc(y2);

    %%

    y3 = step(hautoth, y2);       % Binarize the image.

    %%
    Centroid = step(hblob, y3);   % Calculate the centroid
    numBlobs = size(Centroid,1);  % and number of cells.
    % Display the number of frames and cells.