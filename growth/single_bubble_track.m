% this function tries to find outline of a single bubble from frames

function [bubble_edge, bubble_size]=single_bubble_track(bubble_area,verbose)
N=length(bubble_area);
bubble_size=zeros(N,1);
for i=N:-1:1
    Edge0=bubble_area{i};
    Edge =edge(Edge0 ,'Canny',[0.05 0.2],2);
    Edge1 = bwareafilt(Edge,1);
    %Edge5=JN1{i_count,j_count} ;
    Edge2 = imclose(Edge1, ones(4));
    Edge5=imfill(Edge2,'holes');
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