function [max_values,max_locations,center_locations]= find_circle_sizes(filename,frames,circles)

frame_size=length(frames);
circle_size=length(circles);
max_values=zeros(frame_size,circle_size);
max_locations=zeros(frame_size,circle_size,2);
center_locations=zeros(frame_size,2);

[folder,name,ext] = fileparts(filename);
 
if ~exist([folder,'/frame_circle_compare'], 'dir')
    mkdir([folder,'/frame_circle_compare']);
end

[frame_sizex,frame_sizey]=size(frames{1});
[circle_sizex,circle_sizey]=size(circles{1});
centerx=floor((frame_sizex+circle_sizex-1)/2);
centery=floor((frame_sizey+circle_sizey-1)/2);
crange=20;
for i=1:1:frame_size
    for j=1:1:circle_size

        C=normxcorr2(circles{j},frames{i});
        temp=C(centerx-crange:centerx+crange,centery-crange:centery+crange);
        [V1,I1]=max(temp);
        [V2,I2]=max(V1);
        
        max_locations(i,j,1)=I1(I2)+centerx-crange-1;
        max_locations(i,j,2)=I2+centery-crange-1;
        
        max_values(i,j)=V2;
        
    end
    [V3, I3]=max(max_values(i,:));
    centerx=max_locations(i,I3,1);
    centery=max_locations(i,I3,2);
    center_locations(i,1)=centerx;
    center_locations(i,2)=centery;
    [centerx centery]
end