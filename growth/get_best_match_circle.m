%% this function finds the circle that matches the best
function [circle_matched,circle_size,circle_blur,max_values...
    particle_position,particle_radius]=...
    get_best_match_circle(bubble_area,circle_temps,...
    circle_diameter,blur_list,size_estimate,blur_estimate)

[N1,N2]=size(circle_temps);
proximity1=20;
proximity2=5;
crange=10;

if size_estimate==0
    size_lower=1;
    size_upper=N1;
else
    size_lower=max(1,size_estimate-proximity1);
    size_upper=min(length(circle_diameter),size_estimate+0*proximity1);
end
if blur_estimate==0
    blur_lower=1;
    blur_upper=N2;
else
    blur_lower=max(1,blur_estimate-proximity2);
    blur_upper=min(length(blur_list),blur_estimate+proximity2);
end
[frame_sizex,frame_sizey]=size(bubble_area);
[circle_sizex,circle_sizey]=size(circle_temps{1});
centerx=floor((frame_sizex+circle_sizex-1)/2);
centery=floor((frame_sizey+circle_sizey-1)/2);


max_values=zeros(N1,N2);
max_locations=zeros(N1,N2,2);
for i=blur_lower:1:blur_upper
    for j=size_lower:1:size_upper
        
        C=normxcorr2(circle_temps{j,i},bubble_area);
        temp=C(centerx-crange:centerx+crange,centery-crange:centery+crange);
        [V1,I1]=max(temp);
        [V2,I2]=max(V1);
        
        max_locations(j,i,1)=I1(I2)+centerx-crange-1;
        max_locations(j,i,2)=I2+centery-crange-1;
        
        max_values(j,i)=V2;
    end
end
[V3, I3]=max(max_values(size_lower:size_upper,blur_lower:blur_upper));
[V4, I4]=max(V3);
circle_size_estimate=I3(I4)+size_lower-1;
blur_estimation=I4+blur_lower-1;
centerx=max_locations(circle_size_estimate,blur_estimation,1);
centery=max_locations(circle_size_estimate,blur_estimation,2);

circle_matched=circshift(...
    padarray(circle_temps{circle_size_estimate,blur_estimation},...
    [frame_sizex-circle_sizex frame_sizey-circle_sizey],'post'),...
    [centerx-circle_sizex centery-circle_sizey]);
circle_size=circle_size_estimate;
circle_blur=blur_estimation;
particle_position=[centerx-circle_sizex/2 centery-circle_sizey/2];
particle_radius=circle_diameter(circle_size_estimate);
end