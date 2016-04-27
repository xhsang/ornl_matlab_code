% merge cell images

function big_image=merge_cell_image(images,step1,step2)
[frame_sizex,frame_sizey]=size(images);
[circle_sizex,circle_sizey]=size(images{1});
num1=floor(frame_sizex/step1)+1;
num2=floor(frame_sizey/step2)+1;
big_image=zeros(num1*circle_sizex,num2*circle_sizey);
i=1;
for i_count=1:step1:frame_sizex
    j=1;
    for j_count=1:step2:frame_sizey
        big_image(1+(i-1)*circle_sizex:i*circle_sizex,...
            1+(j-1)*circle_sizey:j*circle_sizey)=...
            images{i_count,j_count};
        j=j+1;
    end
    i=i+1;
end
end