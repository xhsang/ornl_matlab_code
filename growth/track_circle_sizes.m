function [max_values,max_locations,center_locations,peak_location,bubble_size]=...
    track_circle_sizes(filename,bubble_area,circles,...
    circle_diameter,verbose,bubble_size_estimate)

N=length(bubble_area);
circle_size=length(circles);
max_values=zeros(N,circle_size);
max_locations=zeros(N,circle_size,2);
center_locations=zeros(N,2);
peak_location=zeros(N,2);
bubble_size=zeros(N,1);
proximity_size=20;

[folder,name,ext] = fileparts(filename);
 
if ~exist([folder,'/frame_circle_compare'], 'dir')
    mkdir([folder,'/frame_circle_compare']);
end

[frame_sizex,frame_sizey]=size(bubble_area{1});
[circle_sizex,circle_sizey]=size(circles{1});
centerx=floor((frame_sizex+circle_sizex-1)/2);
centery=floor((frame_sizey+circle_sizey-1)/2);

crange=10;

end_size=round(sqrt(bubble_size_estimate(end)/pi));
for i=1:1:length(circle_diameter)
    if end_size<circle_diameter(i)
        break;
    end
end 

circle_rough_area=zeros(circle_size,1);
for i=1:1:circle_size
    temp=circles{i};
    BW=im2bw(temp, 0.1);
    BW1{i}=imfill(BW,'holes');
    circle_rough_area(i)=sum(BW1{i}(:));
end
circle_size_estimate=i;
for i=N:-1:1
    if i==N
        lower=1;
        upper=circle_size;
    else
        lower=max(1,circle_size_estimate-proximity_size);
        upper=min(circle_size,circle_size_estimate+proximity_size);
    end

    for j=lower:1:upper

        C=normxcorr2(circles{j},bubble_area{i});
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
    peak_location(i,2)=circle_diameter(circle_size_estimate); % might be more stable
    bubble_size(i)=circle_rough_area(circle_size_estimate);
    if verbose == 1
        f=figure;
        subplot(1,3,1)
        hold on
        imshowpair(bubble_area{i},circshift(...
            padarray(circles{circle_size_estimate},...
            [frame_sizex-circle_sizex frame_sizey-circle_sizey],'post'),...
            [centerx-circle_sizex centery-circle_sizey]),'montage');
        %plot(centerx,centery);
        subplot(1,3,2);
        plot(max_values(i,:));
        subplot(1,3,3)
        bw_expand=padarray(BW1{circle_size_estimate},...
            [frame_sizex-circle_sizex frame_sizey-circle_sizey],'post');
        bw_shift=circshift(bw_expand,...
            [centerx-circle_sizex centery-circle_sizey]);
        imshowpair(bubble_area{i},bw_shift);
        
        print(f,'-dtiff', '-r300', [folder,'/frame_circle_compare/frame',num2str(i),'.tiff']);
        close(f);
    end
end