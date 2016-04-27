% merge cell images

function big_image=merge_cell_image_1D(images,step,gap)
frame_size=length(images);
[sizex,sizey]=size(images{1});
num=floor(frame_size/step)+1;
p=floor(sqrt(num));
q=ceil(num/p);
big_image=255*ones(p*(sizex+gap),q*(sizey+gap));
count=1;
for i=1:step:frame_size
    p1=ceil(count/q);
    q1=mod(count,q);
    if q1==0
        q1=q;
    end
    big_image(1+(p1-1)*(sizex+gap):p1*(sizex+gap)-gap,...
        1+(q1-1)*(sizey+gap):q1*(sizey+gap)-gap)=...
        images{i}*255/max(images{i}(:));
    count=count+1;
end
end