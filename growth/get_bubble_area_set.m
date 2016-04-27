% this function gets the bubble area
function [bubble_area_set]=get_bubble_area_set...
    (ImageFrames,step_size,r,style,verbose,para1,mini_size)
% ImageFrame: frames in the video
% step_size: step between two frames
% r: the rectangle that defines the bubble area
% style == 1: no filter
% style == 2: JN
i_count=1;
for i=1:step_size:length(ImageFrames)
    if r(3)<mini_size(1)
        max_width=mini_size(1);
    else
        max_width=r(3);
    end
    if r(4)<mini_size(2)
        max_height=mini_size(2);
    else
        max_height=r(4);
    end
    
    start_x=floor(r(1)+r(3)/2-max_width/2);
    start_y=floor(r(2)+r(4)/2-max_height/2);
    temp=imcrop(ImageFrames{i},...
        [start_x start_y max_width max_height]);
    if style == 1
    bubble_area_set{i_count}=temp;
    end
    if style == 2
        bubble_area_set{i_count}=...
            CoherenceFilter(temp,struct('T',5,'rho',5,'Scheme','N','verbose','none'));
    end
    if style == 3
        bubble_area_set{i_count}=imgaussfilt(temp,para1);
    end
    i_count=i_count+1;
end
if verbose == 1
    f=figure;
    p=ceil(sqrt(length(bubble_area_set)));
    q=ceil(length(bubble_area_set)/p);
    for i=1:1:length(bubble_area_set)
        subplot(p,q,i);
        imagesc(bubble_area_set{i});
        axis image off;
        colormap(gray);
    end
end

end