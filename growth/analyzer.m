% here we start to analyze multiple nanoparticles

%% start from simple testing
particle_range=50;
pn=16;
lx=floor(seeds_location(pn,2))
ly=floor(seeds_location(pn,1))

[frame_dimension_x frame_dimension_y]=size(ImageFrames{1});

for j=1:1:length(ImageFrames)
    one_particle=ImageFrames{j}(...
        max(1,lx-particle_range):min(lx+particle_range,frame_dimension_x),...
        max(1,ly-particle_range):min(ly+particle_range,frame_dimension_y));
    one_particle_frame{j}=one_particle;
end

%% show those frames
figure
subplot(2,2,1); imagesc(one_particle_frame{5}); axis image; colormap(gray);
subplot(2,2,2); imagesc(one_particle_frame{25}); axis image; colormap(gray);
subplot(2,2,3); imagesc(one_particle_frame{45}); axis image; colormap(gray);
subplot(2,2,4); imagesc(one_particle_frame{65}); axis image; colormap(gray);

%%
tic
[max_values,max_locations,center_locations,peak_location]=...
    find_circle_sizes(video_file_name, one_particle_frame,circle_temps,1);
toc

%%
plot(peak_location)

%% build up the a big function for everything

particle_range=50;
for pn=1:1:length(seeds_location)
    
    
    lx=floor(seeds_location(pn,2))
    ly=floor(seeds_location(pn,1))
    
    [frame_dimension_x frame_dimension_y]=size(ImageFrames{1});
    
    for j=1:1:length(ImageFrames)
        one_particle=ImageFrames{j}(...
            max(1,lx-particle_range):min(lx+particle_range,frame_dimension_x),...
            max(1,ly-particle_range):min(ly+particle_range,frame_dimension_y));
        one_particle_frame{j}=one_particle;
    end
    
    tic
    [max_values_group{pn},max_locations_group{pn},...
        center_locations_group{pn},peak_location_group{pn}]=...
        find_circle_sizes(video_file_name, one_particle_frame,...
        circle_temps,circle_temps_diameter,0);
    toc
    
end

%%
scale_bar=0.5/78;
%% plot all the growth curves in one figure
hold all
for i=1:1:length(seeds_location)
    plot(peak_location_group{i}(:,2).^2*scale_bar*1000);
end

%% plot growth curves in small sub figures
figure
for i=1:1:length(seeds_location)
    subplot(4,5,i);
    plot(peak_location_group{i}(:,2));
    title(num2str(i));
end

%%
imagesc(max_values_group{6});