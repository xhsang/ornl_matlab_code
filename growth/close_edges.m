function Edge=close_edges(E, verbose)
CC=bwconncomp(E);
[convex_poly] = regionprops(CC,...
    'ConvexImage','ConvexHull','PixelIdxList','PixelList');
areas_in_pixels = cellfun(@length, CC.PixelIdxList);
[temp, idx] = sort(areas_in_pixels,'descend');
%
Edge=zeros(size(E));
Edge(convex_poly(idx(1)).PixelIdxList)=1;
if verbose
    figure
    subplot(1,2,1);
    imshow(Edge);
end
%
conn=[1 1 1;1 0 1;1 1 1];
Edge_skeleton=bwmorph(Edge,'skel');
% connectivity_map=conv2(Edge,conn,'same');
% connectivity_map(~Edge)=0;
Edge_end=bwmorph(Edge_skeleton,'endpoints');
[row,col]=find(Edge_end==1);
[sizex,sizey]=size(Edge_end);
if numel(row) == 2 % if there are two ending points, connect them
    line_pixel_num=max(abs(row(2)-row(1)),abs(col(2)-col(1)));
    line_pixels=zeros(line_pixel_num+1,2);
    if row(2)~=row(1)
        line_pixels(:,1)=round(row(1):(row(2)-row(1))/(line_pixel_num):row(2));
    else
        line_pixels(:,1)=ones(line_pixel_num+1,1)*row(1);
    end
    if col(1)~=col(2)
        line_pixels(:,2)=round(col(1):(col(2)-col(1))/(line_pixel_num):col(2));
    else
        line_pixels(:,2)=ones(line_pixel_num+1,1)*col(1);
    end
    line_index=line_pixels(:,1)+(line_pixels(:,2)-1)*sizex;
    Edge(line_index)=1;
end
if verbose
    subplot(1,2,2);
    imshow(Edge);
end
end