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


subplot(1,2,1);
imagesc(C);
axis image
colormap(gray);
%figure
subplot(1,2,2);
imagesc(C>0.25);
axis image
colormap(gray);

end