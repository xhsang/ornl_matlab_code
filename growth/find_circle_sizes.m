function [max_values,max_locations,center_locations,peak_location]=...
    find_circle_sizes(filename,frames,circles,circle__diameter,verbose)

frame_size=length(frames);
circle_size=length(circles);
max_values=zeros(frame_size,circle_size);
max_locations=zeros(frame_size,circle_size,2);
center_locations=zeros(frame_size,2);
peak_location=zeros(frame_size,2);
proximity_size=5;

[folder,name,ext] = fileparts(filename);
 
if ~exist([folder,'/frame_circle_compare'], 'dir')
    mkdir([folder,'/frame_circle_compare']);
end

[frame_sizex,frame_sizey]=size(frames{1});
[circle_sizex,circle_sizey]=size(circles{1});
centerx=floor((frame_sizex+circle_sizex-1)/2);
centery=floor((frame_sizey+circle_sizey-1)/2);
crange=20;
circle_size_estimate=0;
for i=frame_size:-1:1
    if circle_size_estimate==0
        lower=1;
        upper=circle_size;
    else
        lower=max(1,circle_size_estimate-proximity_size);
        upper=min(circle_size,circle_size_estimate+proximity_size);
    end
    for j=lower:1:upper

        C=normxcorr2(circles{j},frames{i});
        temp=C(centerx-crange:centerx+crange,centery-crange:centery+crange);
        [V1,I1]=max(temp);
        [V2,I2]=max(V1);
        
        max_locations(i,j,1)=I1(I2)+centerx-crange-1;
        max_locations(i,j,2)=I2+centery-crange-1;
        
        max_values(i,j)=V2;
        
    end
    
    
    [V3, I3]=max(max_values(i,lower:upper));
    circle_size_estimate=I3+lower-1;
    
    centerx=max_locations(i,circle_size_estimate,1);
    centery=max_locations(i,circle_size_estimate,2);
    center_locations(i,1)=centerx;
    center_locations(i,2)=centery;
    [centerx centery]
    
    [fr,e,BestStart,xi,yi]=...
        peakfit(max_values(i,:),circle_size_estimate,...
        proximity_size*2+1,1);
    peak_location(i,1)=fr(2); % from peak fitting
    peak_location(i,2)=circle__diameter(circle_size_estimate); % might be more stable
    
    if verbose == 1
        f=figure;
        imshowpair(frames{i},circles{circle_size_estimate},'blend');
        print(f,'-dtiff', '-r300', [folder,'/frame_circle_compare/frame',num2str(i),'.tiff']);
        close(f);
    end
end