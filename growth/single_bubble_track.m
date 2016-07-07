% this function tries to find outline of a single bubble from frames

function [bubble_edge, bubble_size]=single_bubble_track(bubble_area,verbose,constraint,guass_blur)

% constraint tells us if we want to constraint edge detector area
% normally we deal with nanoparticle growth
% if contraint == 1, 
% particle in previous frame is totally 
% included by the next frame

close_size=100;
[sizex,sizey]=size(bubble_area{1});

N=length(bubble_area);
bubble_size=zeros(N,1);
for i=N:-1:1
    Edge0=bubble_area{i};
    Edge =edge(Edge0 ,'Canny',[0.05 0.2],guass_blur);
    if constraint==1 && i<N
        last_edge=bwmorph(bubble_edge{i+1},'thicken',5);
        Edge(last_edge==0)=0;
    end
    
    Edge2=padarray(Edge,[close_size close_size]);
    Edge2 = bwareafilt(Edge2,[10 sizex*sizey]);
    if constraint==1 && i<N
        Edge2 = imclose(Edge2, ones(3));
    end
    Edge1 = bwareafilt(Edge2,1);
    %Edge5=JN1{i_count,j_count} ;
    
    Edge3 = imclose(Edge1, ones(close_size));
    Edge4 = Edge3(close_size+1:close_size+sizex,...
        close_size+1:close_size+sizey);
    Edge5=imfill(Edge4,'holes');
    % if Edge5 is a thin line still have to fill it
    
    bubble_edge{i}=Edge5;
    bubble_size(i)=sum(Edge5(:));
end
if verbose > 0
    f=figure;
    p=ceil(sqrt(N));
    q=ceil(N/p);
    for i=1:1:N
        subplot(p,q,i);
        if verbose == 1
            imshowpair(bubble_edge{i},bubble_area{i},'montage');
        else
            imshowpair(bubble_edge{i},bubble_area{i});
        end
        axis image off;
        colormap(gray);
    end
end
end