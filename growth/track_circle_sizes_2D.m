function [circle_matched, bubble_size,...
    particle_position,particle_radius]=...
    track_circle_sizes_2D(filename,bubble_area,circles,...
    circle_diameter,blur_list,verbose)

N=length(bubble_area);
circle_size=length(circles);
bubble_size=zeros(N,1);
particle_position=zeros(N,2);
particle_radius=zeros(N,1);

[folder,name,ext] = fileparts(filename);
 
if ~exist([folder,'/frame_circle_compare'], 'dir')
    mkdir([folder,'/frame_circle_compare']);
end

size_estimate=0;
blur_estimate=0;
for i=N:-1:1
    
    [circle_matched{i},circle_size,circle_blur,max_value,...
        particle_position(i,:),particle_radius(i)]=...
        get_best_match_circle(bubble_area{i},circles,...
        circle_diameter,blur_list,size_estimate,blur_estimate);
    size_estimate=circle_size;
    blur_estimate=circle_blur;
    
    BW=im2bw(circle_matched{i}, 0.1);
    BW1=imfill(BW,'holes');
    bubble_size(i)=sum(BW1(:));
    
    % one more function to 
    
    if verbose == 1
        f=figure;
        subplot(2,2,1)
        imshowpair(bubble_area{i},circle_matched{i},'montage');
        subplot(2,2,2);
        imshowpair(bubble_area{i},circle_matched{i});
        subplot(2,2,3);
        plot(max_value,'o');
        subplot(2,2,4);
        imshowpair(bubble_area{i},BW1);
        
        print(f,'-dtiff', '-r300', [folder,'/frame_circle_compare/frame',num2str(i),'.tiff']);
        close(f);
    end
end