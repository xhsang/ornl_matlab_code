function seeds_location=find_seeds(image_frame,gsize,gsigma,threshold,verbose)

% image_frame: the image we use to find seeds
% gsize: size of the gaussian peak template
% gsigma: sigma of the gaussian peak
% verbose: output results as figures or not

if verbose == 1
    figure;
end

template=fspecial('gaussian',gsize,gsigma);
C=normxcorr2(template,image_frame);

edge=(gsize+1)/2;
[ImageX, ImageY]=size(image_frame);

D=C(edge:edge+ImageX-1,edge:edge+ImageY-1);  % this might be a different way to get the peak position
%D=ImageSum;
C_backup=C;
C(C<threshold)=0;
C(C>threshold)=1;
seeds_area=image_frame.*C(edge:edge+ImageX-1,edge:edge+ImageY-1);

% show the seeds area picture
if verbose ==1
    subplot(2,2,1);
    colormap(gray);
    imagesc(seeds_area);
    axis image;
end

CC=bwconncomp(seeds_area);
areas_in_pixels = cellfun(@length, CC.PixelIdxList);
fprintf('total peaks found: %d areas range from %d to %d\n',CC.NumObjects,min(areas_in_pixels),max(areas_in_pixels));
fprintf('peaks with areas larger than 10 pixels: %d\n',length(areas_in_pixels(areas_in_pixels>10)));
fprintf('peaks with areas larger than 20 pixels: %d\n',length(areas_in_pixels(areas_in_pixels>20)));

area_size=[1:1:20];
h_area=hist(areas_in_pixels,area_size);

if verbose ==1
    subplot(2,2,2);
    plot(h_area);
end

centroid = regionprops(CC, 'centroid');

indexj=1;
for j=1:1:CC.NumObjects
    seeds_location(indexj,1:2)=centroid(j).Centroid;
    indexj=indexj+1;   
end

if verbose ==1
    subplot(2,2,3);
    imagesc(image_frame);
    for j=1:1:CC.NumObjects
        text(seeds_location(j,1),seeds_location(j,2),'p');
    end
end

end