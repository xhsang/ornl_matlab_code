function [B, Combined,particle_rect,particle_size,...
    max_height,max_width]...
    =filter_particles(BW2, C_threshold, verbose)
[B,L,N] = bwboundaries(BW2);
%get stats
stats=  regionprops(L, 'Centroid', 'Area', 'Perimeter','BoundingBox');
Centroid = cat(1, stats.Centroid);
Perimeter = cat(1,stats.Perimeter);
Area = cat(1,stats.Area);
CircleMetric = (Perimeter.^2)./(4*pi*Area);  %circularity metric
SquareMetric = NaN(N,1);
TriangleMetric = NaN(N,1);
%for each boundary, fit to bounding box, and calculate some parameters
if verbose == 1
    figure(1);
    hold all;
    imagesc(BW2);
    axis image
    colormap(gray)
    axis off
end
for k=1:N,
   boundary = B{k};
   [rx,ry,boxArea] = minboundrect( boundary(:,2), boundary(:,1));  %x and y are flipped in images
   %get width and height of bounding box
   width = sqrt( sum( (rx(2)-rx(1)).^2 + (ry(2)-ry(1)).^2));
   height = sqrt( sum( (rx(2)-rx(3)).^2+ (ry(2)-ry(3)).^2));
   aspectRatio = width/height;
   if aspectRatio > 1,  
       aspectRatio = height/width;  %make aspect ratio less than unity
   end
   SquareMetric(k) = aspectRatio;    %aspect ratio of box sides
   TriangleMetric(k) = Area(k)/boxArea;  %filled area vs box area
   if verbose == 1
       plot(rx,ry,'r','linewidth',2);
   end
end


%define some thresholds for each metric
%do in order of circle, triangle, square, rectangle to avoid assigning the
%same shape to multiple objects
isCircle =   (CircleMetric < 1.1);
isTriangle = ~isCircle & (TriangleMetric < 0.6);
isSquare =   ~isCircle & ~isTriangle & (SquareMetric > 0.9);
isRectangle= ~isCircle & ~isTriangle & ~isSquare;  %rectangle isn't any of these
%assign shape to each object
whichShape = cell(N,1);  
whichShape(isCircle) = {'Circle'};
whichShape(isTriangle) = {'Triangle'};
whichShape(isSquare) = {'Square'};
whichShape(isRectangle)= {'Rectangle'};
%now label with results

max_width=1;
max_height=1;
if verbose ==1
    figure(2);
    RGB = label2rgb(L);
    imshow(RGB); hold on;
    Combined = [CircleMetric, SquareMetric, TriangleMetric];
    count=1;
    for k=1:N
        if CircleMetric(k) > C_threshold
            
            continue;
        end
        particle_size(count)=Area(k);
        particle_rect{count}=stats(k).BoundingBox;
        erode=5;
        particle_rect{count}(1)=stats(k).BoundingBox(1)-erode;
        particle_rect{count}(2)=stats(k).BoundingBox(2)-erode;
        particle_rect{count}(3)=stats(k).BoundingBox(3)+2*erode;
        particle_rect{count}(4)=stats(k).BoundingBox(4)+2*erode;
        if max_width<particle_rect{count}(3)
            max_width=particle_rect{count}(3);
        end
        if max_height<particle_rect{count}(4)
            max_height=particle_rect{count}(4);
        end
        count=count+1;
        %display metric values and which shape next to object
        Txt = sprintf('C=%0.3f S=%0.3f T=%0.3f',  Combined(k,:));
        %text( Centroid(k,1)-20, Centroid(k,2), Txt);
        text( Centroid(k,1)-20, Centroid(k,2), whichShape{k});
    end
    count
end

% the last step is to return the rectangles
end