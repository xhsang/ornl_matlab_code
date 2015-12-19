%% we use this matlab file to quantitatively analyze particles, the shape
%the growth and stuff

%% assign the video file name
video_file_name='/Users/xs1/Documents/Pt_EXP_14_SS6_40kx_trimmed.m4v';

%% get information of the video if it is avi form
% simply to check if that the 
aviinfo(video_file_name)

%% read the video
xyloObj=VideoReader(video_file_name);
nof=xyloObj.NumberOfFrames;

%% read the first frame
xyloObj=VideoReader(video_file_name);
vidWidth = xyloObj.Width;
vidHeight = xyloObj.Height;
mov = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'),...
    'colormap',[]);

mov(1).cdata = readFrame(xyloObj);
figure;
imagesc(mov(1).cdata);
axis image
colormap(gray);

%% select the area to read
figure;
imagesc(mov(1).cdata);
axis image;
colormap(gray);

h = imrect;

position = wait(h);
position=floor(position);
read_rangex=position(2):1:position(2)+position(4);
read_rangey=position(1):1:position(1)+position(3);
read_area=mov(1).cdata(read_rangex,read_rangey);
imagesc(read_area);
axis image

%% output some frames so we know which ones have complete scan
xyloObj=VideoReader(video_file_name);

[folder,name,ext] = fileparts(video_file_name);
 
if ~exist([folder,'/example_frames'], 'dir')
    mkdir([folder,'/example_frames']);
end

k=1;
for k=1:1:100
    current_frame=readFrame(xyloObj);
    imwrite(current_frame(read_rangex,read_rangey),[folder,'/example_frames/frame',num2str(k),'.jpg'],'jpg');
end

%% read and output the key frames

first_frame=11;
second_frame=55;
frame_interval=second_frame-first_frame;
k=0;

if ~exist([folder,'/key_frames'], 'dir')
    mkdir([folder,'/key_frames']);
end

tic
xyloObj=VideoReader(video_file_name);
key_frame=first_frame;
j=1;

while hasFrame(xyloObj)
    current_frame=readFrame(xyloObj);
    if k==key_frame
        imwrite(current_frame(read_rangex,read_rangey),[folder,'/key_frames/frame'...
            ,num2str(k),'.jpg'],'jpg');
        key_frame=key_frame+frame_interval;
        ImageFrames{j} = double(rgb2gray(current_frame));
        ImageFrames{j}=ImageFrames{j}(read_rangex,read_rangey);
        j=j+1;
    end
    k=k+1;
end
k
toc
key_frame_num=j-1;


%% find the seeds from the first frame
% ignore
figure;
imagesc(ImageFrames{1});
axis image;
colormap(gray);

h = imrect;

position = wait(h);
position=floor(position);
cc_rangex=position(2):1:position(2)+position(4);
cc_rangey=position(1):1:position(1)+position(3);
small_area=ImageFrames{1}(cc_rangex,cc_rangey);
imagesc(small_area);

%%
% ignore
figure;
imagesc(small_area);
axis image;
colormap(gray);

h = imrect;

position = wait(h);
position=floor(position);
cc_rangex=position(2):1:position(2)+position(4);
cc_rangey=position(1):1:position(1)+position(3);
template=small_area(cc_rangex,cc_rangey);
imagesc(template);
%% use the gaussian distribution template
% the gaussian template seems to work better
% than an area arbitrarily selected from the image
figure;
template=fspecial('gaussian',41,1);
C=normxcorr2(template,ImageFrames{1});
subplot(1,2,1);
imagesc(C);
axis image
colormap(gray);
%figure
subplot(1,2,2);
imagesc(C>0.25);
axis image
colormap(gray);

%%
r=-1:0.01:1;
h=hist(C(:),r);
plot(r,h);
xlim([0.1 0.5]);

%% it is time to create a function to find the seeds
%seeds_location=find_seeds(ImageFrames{1},gsize,gsigma,threshold)
seeds_location=find_seeds(ImageFrames{1},41,1,0.25,1);

%% plot the seeds location on the image
figure
imagesc(ImageFrames{1});
axis image
colormap(gray);
for j=1:1:length(seeds_location)
    text(seeds_location(j,1),seeds_location(j,2),'o');
end

%% now we can focus on one particle
 
if ~exist([folder,'/one_particle'], 'dir')
    mkdir([folder,'/one_particle']);
end
particle_range=50;
lx=floor(seeds_location(pn,2))
ly=floor(seeds_location(pn,1))
pn=4;
for j=1:1:length(ImageFrames)
    one_particle=ImageFrames{j}(...
        lx-particle_range:lx+particle_range,...
        ly-particle_range:ly+particle_range);
    one_particle_frame{j}=one_particle;
    imwrite(one_particle/max(one_particle(:)),[folder,'/one_particle/frame',num2str(j),'.jpg'],'jpg');
end

%% show those frames
figure
subplot(2,2,1); imagesc(one_particle_frame{5}); axis image; colormap(gray);
subplot(2,2,2); imagesc(one_particle_frame{15}); axis image; colormap(gray);
subplot(2,2,3); imagesc(one_particle_frame{25}); axis image; colormap(gray);
subplot(2,2,4); imagesc(one_particle_frame{35}); axis image; colormap(gray);
%% now find the size of those particles
[centers, radii, metric] = imfindcircles(one_particle_frame{15},[15 22]);
viscircles(centers, radii,'EdgeColor','b');

%%
I=one_particle_frame{15};
Iblur = imgaussfilt(I, 1);
imagesc(Iblur);
%%
BW1 = edge(Iblur,'Canny',0.4);
imshowpair(BW1,one_particle_frame{15},'blend')

%%
[centers, radii, metric] = imfindcircles(BW1,[5 10]);
imagesc(Iblur);
viscircles(centers, radii,'EdgeColor','b');

%% how about crosscorrelating

imagesc(I)
colormap(gray);

%% create a template with a thin circle
ctemp_size=21;
circle_size=6;
centerx=(ctemp_size+1)/2;
centery=(ctemp_size+1)/2;
ctemp=zeros(ctemp_size,ctemp_size);
for i=1:1:ctemp_size
    for j=1:1:ctemp_size
        d=sqrt((i-centerx)^2+(j-centery)^2);
        if round(d)==circle_size
            ctemp(i,j)=1;
        end
    end
end
imagesc(ctemp);

%% use this function to get a bunch of circles, either blurred or not
ctemp_size=51;
circle_temps=get_circle_templates(1:0.2:20,ctemp_size,0.5);
%% test this on one frame to see if that works
max_values=zeros(length(circle_temps),1);
for i=1:1:length(circle_temps)
    C=normxcorr2(circle_temps{i},I);
    subplot(8,9,i);
    imagesc(C(50:100,50:100));
    temp=C(50:100,50:100);
    max_values(i)=max(temp(:));
    axis image
    colormap(gray);
end

%% find the circle sizes for all the frames
tic
[max_values,max_locations,center_locations]=find_circle_sizes(video_file_name, one_particle_frame,circle_temps);
toc
%%
[V, index]=max(max_values);
imshowpair(I,circle_temps{index},'blend');
%%
hold all
plot(3:0.1:10,max_values)
plot(3:0.1:10,max_value_noblur)
plot(3:0.1:10,max_value_blur1)
