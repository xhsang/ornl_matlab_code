% the previous method does not seem to work very well
% the shape of large bubbles is definetely something to investigate

%%
figure;
imagesc(ImageFrames{100});
axis image;
colormap(gray);

%% maybe filter the background first
I=clear_background(ImageFrames{361},20,0);
imshowpair(I,ImageFrames{361},'montage');

%%
I=ImageFrames{201};

%% try canny edge finder
BW =edge(I_signal,'Canny',0.1,5);
imshowpair(BW,I)

%% try a different edge finder

BW =edge(I,'zerocross',0);
imshowpair(BW,ImageFrames{100},'montage')
%%
I=ImageFrames{101};
%I=clear_background(I,10,0);
I1 = 2*I - imdilate(I, strel('square',5));
imshowpair(I1,I,'montage');

%%
I2 = imtophat(I, strel('disk', 5));
imshowpair(I2,I,'montage');
%%
I1(I1<0) = 0;
I1(I1>1) = 1;
imshowpair(I1,I,'montage');

%% this works like a charm
I2 = imdilate(I1, strel('square',15)) - I1;
imshowpair(I1,I2,'montage');

%%
level = graythresh(I2);
BW = im2bw(I2,0.2);
imshow(BW)

%% this watershed thing does not seem to work
D = -bwdist(~BW);
D(~BW) = -Inf;
L = watershed(D);
imshow(label2rgb(L,'jet','w'))

%%
background = imopen(I,strel('disk',5));
imagesc(background);

%%
I_signal=I-background;
imagesc(I_signal);

%%
I=I_signal;
I1 = 2*I - imdilate(I, strel('square',15));
imshowpair(I1,I,'montage');

%%
I3 = imadjust(I_signal);
imshow(I3);

%%
hautoth = vision.Autothresholder( ...
    'Operator', '<=', ...
    'ThresholdScaleFactor', 0.8);
I3=step(hautoth,I2);

imshowpair(1-I1,1-I3,'montage');

%% now we should find the good edges and get rid of the bad edges
CC=bwconncomp(1-I3);
areas_in_pixels = cellfun(@length, CC.PixelIdxList);
centroid = regionprops(CC, 'centroid');
area_size=[1:1:2000];
h_area=hist(areas_in_pixels,area_size);

figure;
plot(h_area);
ylim([0 20]);

%% find several largest chunks
[temp, idx] = sort(areas_in_pixels,'descend');
imshow(1-I3);
hold on
for i=1:1:10
    index=idx(i);
    areas_in_pixels(index)
    plot(centroid(index).Centroid(1),...
        centroid(index).Centroid(2), 'ro',...
        'Markersize',30);
end
hold off

%% get rid of small areas
% here we define a number called max_bubble_number
max_bubble_number=50;
I4 = bwareaopen(1-I3, areas_in_pixels(idx(max_bubble_number)));
imshowpair(I4,1-I3,'montage');

%% now use the noise-reduced image, we redo the calculations
CC=bwconncomp(I4);
areas_in_pixels = cellfun(@length, CC.PixelIdxList);
centroid = regionprops(CC, 'centroid');
[temp, idx] = sort(areas_in_pixels,'descend');

%% find the convex polygon that covers the crap
[convex_poly] = regionprops(CC, 'ConvexHull','ConvexArea','Solidity');
imshowpair(I4,I,'montage');
hold on
for i=1:1:30
    index=idx(i);
    areas_in_pixels(index)
    temp_poly=convex_poly(index).ConvexHull;
    convex_poly(index).ConvexArea/areas_in_pixels(index)
    if convex_poly(index).Solidity<0.5
        plot(temp_poly(:,1),...
            temp_poly(:,2), 'r-','linewidth',2);
    else
        plot(temp_poly(:,1),...
            temp_poly(:,2), 'g-','linewidth',2);
    end
    %text(centroid(index).Centroid(1),...
    %    centroid(index).Centroid(2),num2str(convex_poly(index).Solidity));
end
%% remove small images
I4 = bwareaopen(1-I3, 10);
imshowpair(I4,I,'montage');
%%
BW =edge(I,'Canny',0.4,3);
imshowpair(BW,I)
%BW=imdilate(BW,strel('diamond',1)) ;
imagesc(BW);

%%
hblob = vision.BlobAnalysis( ...
    'AreaOutputPort', false, ...
    'BoundingBoxOutputPort', false, ...
    'OutputDataType', 'single', ...
    'MinimumBlobArea', 3, ...
    'MaximumBlobArea', 300, ...
    'MaximumCount', 1500);

Centroid = step(hblob, I3)   % Calculate the centroid
numBlobs = size(Centroid,1);  % and number of cells.

%%
figure;
imagesc(I3);
colormap(gray);
hold on;
plot(Centroid(:,1),Centroid(:,2),'or');
%%
[B,L,N,A] = bwboundaries(BW,8);
figure; imagesc(I); hold on;
% Loop through object boundaries
for k = 1:N
    % Boundary k is the parent of a hole if the k-th column
    % of the adjacency matrix A contains a non-zero element
    if (nnz(A(:,k)) > 0)
        boundary = B{k};
        plot(boundary(:,2),...
            boundary(:,1),'r','LineWidth',2);
    end
end

%%
BW2 = bwperim(BW);
imshowpair(BW2,BW,'montage');


%%
figure;
imagesc(ImageFrames{end});
axis image;
colormap(gray);

h = imrect;

position = wait(h);
position=floor(position);
one_bubble_rangex=position(2):1:position(2)+position(4);
one_bubble_rangey=position(1):1:position(1)+position(3);

%%

if ~exist([folder,'/bubble_edges'], 'dir')
    mkdir([folder,'/bubble_edges']);
end

tic
for i=1:10:length(ImageFrames)
    I=ImageFrames{i}(one_bubble_rangex,one_bubble_rangey);
    %I=clear_background(I,10,0);
    BW =edge(I,'Canny',0.3,3);
    [B,L,N,A] = bwboundaries(BW,8);
    f=figure; imagesc(I); hold on;
    % Loop through object boundaries
    for k = 1:N
        % Boundary k is the parent of a hole if the k-th column
        % of the adjacency matrix A contains a non-zero element
        if (nnz(A(:,k)) > 0)
            boundary = B{k};
            plot(boundary(:,2),...
                boundary(:,1),'r','LineWidth',2);
        end
    end
    print(f,'-dtiff', '-r300', [folder,'/bubble_edges/frame',num2str(i),'.tiff']);
    close(f);
end
toc

%% some preprocessing code

if ~exist([folder,'/pre_process'], 'dir')
    mkdir([folder,'/pre_process']);
end

tic
for i=1:10:length(ImageFrames)
    f=figure;
    I=ImageFrames{i};
    I1 = 2*I - imdilate(I, strel('square',15));
    
    I1(I1<0) = 0;
    I1(I1>1) = 1;
    
    I2 = imdilate(I1, strel('square',15)) - I1;
    hautoth = vision.Autothresholder( ...
        'Operator', '<=', ...
        'ThresholdScaleFactor', 0.8);
    I3=step(hautoth,I2);
    
    CC=bwconncomp(1-I3);
    areas_in_pixels = cellfun(@length, CC.PixelIdxList);
    
    [temp, idx] = sort(areas_in_pixels,'descend');
    
    I4 = bwareaopen(1-I3, areas_in_pixels(idx(max_bubble_number)));
    
    CC=bwconncomp(I4);
    areas_in_pixels = cellfun(@length, CC.PixelIdxList);
    centroid = regionprops(CC, 'centroid');
    [temp, idx] = sort(areas_in_pixels,'descend');
    
    [convex_poly] = regionprops(CC, 'ConvexHull','ConvexArea','Solidity');
    imshowpair(I4,I,'montage');
    hold on
    for j=1:1:30
        index=idx(j);
        areas_in_pixels(index)
        temp_poly=convex_poly(index).ConvexHull;
        convex_poly(index).ConvexArea/areas_in_pixels(index)
        if convex_poly(index).Solidity<0.5
            plot(temp_poly(:,1),...
                temp_poly(:,2), 'r-','linewidth',2);
        else
            plot(temp_poly(:,1),...
                temp_poly(:,2), 'g-','linewidth',2);
        end
        %text(centroid(index).Centroid(1),...
        %    centroid(index).Centroid(2),num2str(convex_poly(index).Solidity));
    end
    
    print(f,'-dtiff', '-r300', [folder,'/bubble_edges/frame',num2str(i),'.tiff']);
    close(f);
end
toc

%% top hat function seems to work very well
if ~exist([folder,'/tophat'], 'dir')
    mkdir([folder,'/tophat']);
end

tic
for i=261:10:261%length(ImageFrames)
    I=ImageFrames{i};
    %I=clear_background(I,10,0);
    I2 = imtophat(I, strel('disk', 5));
    Edge =edge(I2,'Canny',0.1,5);
    CC=bwconncomp(Edge);
    [convex_poly] = regionprops(CC, 'ConvexImage','ConvexHull','PixelIdxList');
    temp1=zeros(size(Edge));
    for j=1:1:length(convex_poly)
        temp2=zeros(size(Edge));
        temp2(convex_poly(j).PixelIdxList)=1;
        temp2 = imclose(temp2,strel('disk', 20));
        temp2 = imfill(temp2, 'holes');
        temp1=temp1|temp2;
    end
    %IM2 = imclose(Edge,strel('disk', 5));
% IM2 = imclose(IM2,strel('line', 5,0));
% IM2 = imclose(IM2,strel('line', 5,90));
% IM2 = imclose(IM2,strel('line', 5,45));
% IM2 = imclose(IM2,strel('line', 5,135));
%IM2 = imclose(Edge_sub,strel('disk', 5));
%BWdfill = imfill(IM2, 'holes');
    %     BWsdil = imdilate(Edge, strel('disk', 5));
    %     BWdfill = imfill(BWsdil, 'holes');
    %     BWnobord = imclearborder(BWdfill, 4);
    %     BWfinal = imerode(BWnobord,seD);
    %     BWfinal = imerode(BWfinal,seD);
%     CC=bwconncomp(Edge);
% [convex_poly] = regionprops(CC, 'ConvexImage','ConvexHull');
%     Edge_fill=Edge;

    f=figure;
    imshowpair(temp1,I,'montage');
    
    print(f,'-dtiff', '-r300', [folder,'/tophat/frame',num2str(i),'.tiff']);
    close(f);
end

%%
temp2=zeros(size(Edge));
temp2(convex_poly(10).PixelList')=1;
imshow(temp2)
%%
I=ImageFrames{end}-ImageFrames{end-30};;
%I=clear_background(I,10,0);
I2 = imtophat(I, strel('disk', 5));
Edge =edge(I2,'Canny',0.08,5);
f=figure;
imshowpair(ImageFrames{end-30},I2,'falsecolor','Scaling','independent');

%%
I5=2*ImageFrames{31}-ImageFrames{51}-ImageFrames{11};
Edge5 =edge(I5,'Canny',0.4,5);
imshowpair(Edge5,ImageFrames{31},'falsecolor');

%%
I5=2*ImageFrames{31}-ImageFrames{61};
I5(I5<0) = 0;
I5(I5>1) = 1;
imshow(~I5);

%%

I6 = imdilate(I5, strel('square',15)) - I5;
imshowpair(I6,ImageFrames{61},'montage');
%%
hautoth = vision.Autothresholder( ...
    'Operator', '<=', ...
    'ThresholdScaleFactor', 0.8);
I3=step(hautoth,I2);
%%
I=ImageFrames{61};
I1 = 2*I - imdilate(I, strel('square',5));
Edge5 =edge(I1,'Canny',0.2,5);
imshowpair(I,Edge5,'montage');

%%
I2 = imtophat(I, strel('disk', 5));
Edge =edge(I2,'Canny',0.06,5);
f=figure;
imshowpair(I,I2,'montage');

%%
L = medfilt2(I2,[5 5]);
figure, imagesc([L I2])

%%
K2 = wiener2(I2,[5 5]);
%K2 = imtophat(K, strel('disk', 5));
Edge_K =edge(K2,'Canny',0.08,5);
f=figure;
imshowpair(K,Edge_K,'montage');
%%
mask = zeros(size(Edge_sub));
mask(2:end-2,2:end-2) = 1;
bw = activecontour(Edge_sub,mask,300);
  
figure, imshow(Edge_sub);
title('Segmented Image');
%%
Edge_sub=imcrop(BWdfill);
%%
IM2 = imclose(Edge,strel('disk', 5));
% IM2 = imclose(IM2,strel('line', 5,0));
% IM2 = imclose(IM2,strel('line', 5,90));
% IM2 = imclose(IM2,strel('line', 5,45));
% IM2 = imclose(IM2,strel('line', 5,135));
%IM2 = imclose(Edge_sub,strel('disk', 5));
BWdfill = imfill(IM2, 'holes');
imshowpair(BWdfill,I);

%%
BWdfill = imfill(IM2, 'holes');
imshowpair(BWdfill,I,'montage');
%%
CC=bwconncomp(Edge);
[convex_poly] = regionprops(CC, 'ConvexImage','ConvexHull','PixelList');
%% does not work
Edge_fill=Edge;

hold all;
for i=1:1:length(convex_poly)
    temp=convex_poly(i).ConvexHull;
    %temp=convex_poly(i).PixelList;
    %temp(end+1,:)=temp(1,:);
    BW_mask=poly2mask(temp(:,1), temp(:,2), sizex, sizey);
    Edge_fill=Edge_fill|BW_mask;
    %[V,S] = alphavol(temp,inf);
    %plot(S.bnd(:,1),S.bnd(:,2),'r-');
end
imshowpair(Edge_fill,I,'montage');
hold on;
plot(x,y,'r')
%%
[V,S] = alphavol(temp,inf)

%%
[sizex sizey]=size(ImageFrames{1});
BW_mask=poly2mask(temp(:,2), temp(:,1), sizex, sizey);
imagesc(BW_mask); 
%%

Edge_fill=regionfill(I,temp(:,1),temp(:,2));
imshowpair(Edge,Edge_fill,'montage');
hold all;
plot(temp(:,2),temp(:,1),'r')
%%
se90 = strel('line', 3, 90);
se0 = strel('line', 3, 0);
BWsdil = imdilate(Edge, strel('disk', 5));
imshowpair(Edge,BWsdil,'montage');

%%
BWdfill = imfill(BWsdil, 'holes');
imshowpair(BWdfill,I,'montage');

%%
BWnobord = imclearborder(BWdfill, 4);
imshowpair(BWnobord,I,'montage');

%%
seD = strel('diamond',1);
BWfinal = imerode(BWnobord,seD);
BWfinal = imerode(BWfinal,seD);
imshowpair(BWfinal,I,'montage');

%%
BWoutline = bwperim(BWfinal);
Segout = I;
Segout(BWoutline) = 255;
figure, imagesc(Segout)
%%
CC=bwconncomp(Edge);
areas_in_pixels = cellfun(@length, CC.PixelIdxList);
centroid = regionprops(CC, 'centroid');
[temp, idx] = sort(areas_in_pixels,'descend');

[convex_poly] = regionprops(CC, 'ConvexHull','ConvexArea','Solidity');

%%
labeled = labelmatrix(CC);
RGB_label = label2rgb(labeled, @spring, 'c', 'shuffle');
imshow(RGB_label)
%%
hold on
for j=1:1:30
    index=idx(j);
    areas_in_pixels(index)
    temp_poly=convex_poly(index).ConvexHull;
    convex_poly(index).ConvexArea/areas_in_pixels(index)
    if convex_poly(index).Solidity<0.5
        plot(temp_poly(:,1),...
            temp_poly(:,2), 'r-','linewidth',2);
    else
        plot(temp_poly(:,1),...
            temp_poly(:,2), 'g-','linewidth',2);
    end
    %text(centroid(index).Centroid(1),...
    %    centroid(index).Centroid(2),num2str(convex_poly(index).Solidity));
end

%%
I = imread('eight.tif');
x = [222 272 300 270 221 194];
y = [21 21 75 121 121 75];
%plot(x,y);
J = regionfill(I,x,y);
figure
subplot(1,2,1)
imshow(I)
title('Original image')
subplot(1,2,2)
imshow(J)
title('Image with one less coin')

%%
% 2D Example - C shape
t = linspace(0.6,5.7,500)';
X = 2*[cos(t),sin(t)] + rand(500,2);
subplot(221), alphavol(X,inf,1);
subplot(222), alphavol(X,1,1);
subplot(223), alphavol(X,0.5,1);
subplot(224), alphavol(X,0.2,1);

%%
if ~exist([folder,'/differential'], 'dir')
    mkdir([folder,'/differential']);
end

tic
for i=31:10:length(ImageFrames)-30
    I5=2*ImageFrames{i}-ImageFrames{i-30}-ImageFrames{i+30};
    Edge5 =edge(I5,'Canny',0.4,5);
    
    
    f=figure;
    imshowpair(Edge5,ImageFrames{i},'montage');
    
    print(f,'-dtiff', '-r300', [folder,'/differential/frame',num2str(i),'.tiff']);
    close(f);
end

%% speed map
if ~exist([folder,'/differential'], 'dir')
    mkdir([folder,'/differential']);
end

tic
for i=31:10:length(ImageFrames)-30
    I5=2*ImageFrames{i}-ImageFrames{i-30}-ImageFrames{i+30};
    Edge5 =edge(I5,'Canny',0.4,5);
    
    
    f=figure;
    imshowpair(Edge5,ImageFrames{i},'montage');
    
    print(f,'-dtiff', '-r300', [folder,'/differential/frame',num2str(i),'.tiff']);
    close(f);
end
%%
if ~exist([folder,'/velocity'], 'dir')
    mkdir([folder,'/velocity']);
end

tic
for i=1:1:length(ImageFrames)-30
    I5=ImageFrames{i+30}-ImageFrames{i};
    
    
    f=figure;
    imshowpair(I5,ImageFrames{i});
    
    print(f,'-dtiff', '-r300', [folder,'/velocity/frame',num2str(i),'.tiff']);
    close(f);
end
%%
i=100;
I5=ImageFrames{i+30}-ImageFrames{i};
imagesc(I5);