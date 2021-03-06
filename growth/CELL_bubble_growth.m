%%
i=11;
I5=ImageFrames{end}-ImageFrames{end-30};
imagesc(I5);
colormap(gray);
axis image off


%% select only the particle for analysis
figure;
imagesc(ImageFrames{end});
axis image;
colormap(gray);

h = imrect;

position = wait(h);
position=floor(position);
read_rangex=position(2):1:position(2)+position(4);
read_rangey=position(1):1:position(1)+position(3);
read_area=ImageFrames{end}(read_rangex,read_rangey);
imagesc(read_area);
axis image

%%
R1=I5(read_rangex,read_rangey);
JN = CoherenceFilter(R1,struct('T',10,'rho',5,'Scheme','N'));
%%
Edge5 =edge(JN,'Canny',0.4);
imshowpair(Edge5,I5(read_rangex,read_rangey),'montage');

%%
surf(R1);

%%
I = R1;
JS = CoherenceFilter(I,struct('T',15,'rho',10,'Scheme','S'));
JN = CoherenceFilter(I,struct('T',15,'rho',10,'Scheme','N'));
JR = CoherenceFilter(I,struct('T',15,'rho',10,'Scheme','R'));
JI = CoherenceFilter(I,struct('T',15,'rho',10,'Scheme','I'));
JO = CoherenceFilter(I,struct('T',15,'rho',10,'Scheme','O'));
%%
figure,
subplot(2,3,1), imagesc(I), axis image; title('Before Filtering');
subplot(2,3,2), imagesc(JS),axis image; title('Standard Scheme');
subplot(2,3,3), imagesc(JN),axis image; title('Non Negative Scheme');
subplot(2,3,4), imagesc(JI),axis image; title('Implicit Scheme');
subplot(2,3,5), imagesc(JR),axis image; title('Rotation Invariant Scheme');
subplot(2,3,6), imagesc(JO),axis image; title('Optimized Scheme');


%%
if ~exist([folder,'/outline'], 'dir')
    mkdir([folder,'/outline']);
end

tic
for i=1:10:length(ImageFrames)-30
    I5=ImageFrames{i+30}-ImageFrames{i};
    read_area=I5(read_rangex,read_rangey);
    JN = CoherenceFilter(read_area,struct('T',5,'rho',5,'Scheme','N'));
    Edge5 =edge(JN,'Canny',0.5);
    f=figure;
    imshowpair(read_area,Edge5,'montage');
    
    print(f,'-dtiff', '-r300', [folder,'/outline/frame',num2str(i),'.tiff']);
    close(f);
end



%%
bubble_count=0;
%% select multiple areas
figure
imagesc(ImageFrames{end-137});
axis image
colormap(gray);
for i=1:1:bubble_count
    rectangle('Position', bubble_position{i}, 'LineWidth',2, 'EdgeColor','r');
    text(bubble_position{i}(1),bubble_position{i}(2),num2str(i));
end

h = imrect

uicontrol('Style', 'pushbutton', 'String', 'Done',...
    'Position', [20 20 50 20],...
    'Callback', 'delete(h)');


while isvalid(h)
    p = wait(h);
    if ~isempty(p)
        rectangle('Position', p, 'LineWidth',2, 'EdgeColor','r');
        bubble_count=bubble_count+1;
        bubble_position{bubble_count}=round(p);
    end
end


%% or easily find them from the last frame
endframe=length(ImageFrames)-137;
I5=ImageFrames{endframe};
%I5=cleanimage;
BW =edge(I5,'Canny',[0.05 0.2],3);
BW1 = imclose(BW, ones(1));
%subplot(2,1,1);
%imshowpair(BW,BW1,'montage');
%BW=close_edges(BW,0);
BW2= imfill(BW1,'holes');
%subplot(2,1,2);
imshowpair(BW2,I5,'montage')
%BW=imdilate(BW,strel('diamond',1)) ;
%imagesc(BW);

%% find all the circular objects
% and find the rectangles containing those objects
[B,Combined,bubble_position,particle_size,...
    max_height,max_width]...
    =filter_particles(BW2,1.1,1);
bubble_count=length(bubble_position);

%%
Edge5 =edge(JN,'Canny',0.4);
imshowpair(Edge5,I5,'montage');

%% return all the bubble frames

%% visualize all the particles and frames
step_size=20;
size_threshold=1200;
row_num=sum(particle_size>size_threshold);
col_num=floor((length(ImageFrames)-1)/step_size)+1;
%ha=tight_subplot(row_num,col_num,0.001,0.001,0.001);
count=1;
gap=2;
big_imagex=row_num*(max_height+1)+(row_num-1)*gap;
big_imagey=col_num*(max_width+1)+(col_num-1)*gap;
big_image=255*ones(big_imagex, big_imagey);
fit_result=ones(big_imagex, big_imagey);
j_count=1;
for j=1:1:bubble_count
    if particle_size(j)<=size_threshold
        continue;
    end
    
    i_count=1;
    for i=1:step_size:length(ImageFrames)
        %axes(ha(count));
        r=bubble_position{j};
        start_x=floor(r(1)+r(3)/2-max_width/2);
        start_y=floor(r(2)+r(4)/2-max_height/2);
        bubble_sub=imcrop(ImageFrames{i},...
            [start_x start_y max_width max_height]);
        
        imagex=(j_count-1)*(max_height+1)+(j_count-1)*gap+1;
        imagey=(i_count-1)*(max_width+1)+(i_count-1)*gap+1;
        big_image(imagex:imagex+max_height,...
            imagey:imagey+max_width)=bubble_sub;
        
        %JN1{i_count,j_count} = ...
        %    CoherenceFilter(bubble_sub,struct('T',5,'rho',5,'Scheme','N','verbose','none'));
        Edge0=bubble_sub ;
        %bubble_sub_set{i_count,j_count}=bubble_sub;
        %I1=bubble_sub;
        %Edge0=imdilate(I1, strel('square',3)) - I1;
        Edge =edge(Edge0 ,'Canny',[0.1 0.2],2);
        Edge1 = bwareafilt(Edge,1);
        %Edge5=JN1{i_count,j_count} ;
        Edge2 = imclose(Edge1, ones(4));
        Edge5=imfill(Edge2,'holes');
        
        fit_result(imagex:imagex+max_height,...
            imagey:imagey+max_width)=Edge5;
        
        i_count=i_count+1;
    end
    j_count=j_count+1;
end
imagesc(fit_result); 
axis image off;
colormap(gray);

%%
I1=bubble_sub_set{11,10};
Edge0=imdilate(I1, strel('square',5)) - I1;
Edge =edge(Edge0 ,'Canny',[0.1 0.3],3);
imshowpair(Edge,Edge0,'montage');
%%
Edge1 = bwareafilt(Edge,1);
%Edge5=JN1{i_count,j_count} ;
Edge2 = imclose(Edge1, ones(4));
Edge5=imfill(Edge2,'holes');
%%
imagesc(fit_result); 
axis image off;
colormap(gray);
%% first get the bubble area
area_step=1;
bubble_area_set=get_bubble_area_set(ImageFrames(1:endframe),area_step,...
    bubble_position{1},1,1,1,size(circle_temps{1}));
%%
bubble_area_set_JN=get_bubble_area_set...
    (ImageFrames(1:endframe),area_step,bubble_position{1},2,1,0,size(circle_temps{1}));
%%
bubble_area_set_GS=get_bubble_area_set...
    (ImageFrames(1:endframe),area_step,bubble_position{1},3,1,2,size(circle_temps{1}));

%% then find the outline of this crap JN
[bubble_edge, bubble_size_JN]=single_bubble_track(bubble_area_set_JN,1,1,4);
%% GS
[bubble_edge, bubble_size_GS]=single_bubble_track(bubble_area_set_GS,1,0,3);
%% non blurred
[bubble_edge, bubble_size_non]=single_bubble_track(bubble_area_set(1:end),1,1);
%% some test cases
bubble_area_set_test{1}=circshift(padarray(circle_temps{10},[10 20]),[5 7]);

%% match with the circles
[circle_matched,bubble_size,particle_position,particle_radius]=...
    track_circle_sizes_2D(mat_file_name,bubble_area_set,...
    circle_temps(:,4),...
    circle_temps_diameter,blur_list(4),1);
%% maybe use the circles to modify the raw data crap
range=1:20;
[modified_particle_area,rdf_map]=...
    modify_bubble_area_from_circles(mat_file_name,bubble_area_set(range),...
    circle_matched(range),particle_position(range,:),particle_radius(range),1);
%%
[bubble_edge, bubble_size_rdf_10]=single_bubble_track(modified_particle_area,1,1);
%%
hold all
plot(bubble_size_rdf_20,'o-');
plot(bubble_size_rdf_10,'o-');
%%
hold all
plot(bubble_size_JN,'o');
plot(bubble_size_GS,'d');
plot(bubble_size_non,'o');
%plot(bubble_size_rdf,'s');

%% this works better for lower mag
if ~exist([folder,'/overall'], 'dir')
    mkdir([folder,'/overall']);
end
for i=1:1:bubble_count
    bubble_area_set=get_bubble_area_set(ImageFrames(1:endframe),1,...
        bubble_position{i},1,0,1,size(circle_temps{1}));
    [circle_matched,bubble_size,particle_position,particle_radius]=...
        track_circle_sizes_2D(mat_file_name,bubble_area_set,...
        circle_temps(:,4),...
        circle_temps_diameter,blur_list(4),0);
    range=1:length(bubble_area_set);
    [modified_particle_area,rdf_map]=...
        modify_bubble_area_from_circles(mat_file_name,bubble_area_set(range),...
        circle_matched(range),particle_position(range,:),particle_radius(range),0);
    [bubble_edge_rdf_set{i}, bubble_size_rdf_set{i}]=single_bubble_track(modified_particle_area,0,0);
    [bubble_edge_non_set{i}, bubble_size_non_set{i}]=single_bubble_track(bubble_area_set,0,0);
    f=figure;
    f.PaperPosition=[1 1 17 8];
    subplot(2,3,1);
    hold all;
    plot(bubble_size_rdf_set{i},'s');
    plot(bubble_size_non_set{i},'d');
    subplot(2,3,2);
    bubble_rdf=merge_cell_image_1D(bubble_edge_rdf_set{i},1,2);
    imagesc(bubble_rdf);
    axis image off
    colormap(gray);
    subplot(2,3,3);
    bubble_non=merge_cell_image_1D(bubble_edge_non_set{i},1,2);
    imagesc(bubble_non);
    axis image off
    colormap(gray);
    
    subplot(2,3,4);
    modified_area_big_image=...
        merge_cell_image_1D(modified_particle_area,1,2);
    imagesc(modified_area_big_image);
    axis image off
    colormap(gray);
    
    subplot(2,3,5);
    bubble_area_big_image=...
        merge_cell_image_1D(bubble_area_set,1,2);
    imagesc(bubble_area_big_image);
    axis image off
    colormap(gray);
    
    print(f,'-dtiff', '-r300',...
        [folder,'/overall/bubble_',num2str(i),'.tiff']);
    close(f);
end

%% parameters for 160K
gauss_blur=3;
%% this works better for higher mag (80K)
if ~exist([folder,'/overall'], 'dir')
    mkdir([folder,'/overall']);
end
for i=3:1:bubble_count
    area_step=2;
    bubble_area_set=get_bubble_area_set(ImageFrames(1:endframe),area_step,...
        bubble_position{i},1,0,1,size(circle_temps{1}));
    
    bubble_area_set_JN=get_bubble_area_set(ImageFrames(1:endframe),...
        area_step,bubble_position{i},2,0,0,size(circle_temps{1}));
    
    bubble_area_set_GS=get_bubble_area_set(ImageFrames(1:endframe),...
        area_step,bubble_position{i},3,0,2,size(circle_temps{1}));
    
    [bubble_edge_JN_set{i}, bubble_size_JN_set{i}]=single_bubble_track(bubble_area_set_JN,0,0,gauss_blur);
    
    [bubble_edge_GS_set{i}, bubble_size_GS_set{i}]=single_bubble_track(bubble_area_set_GS,0,0,gauss_blur);
    
    [bubble_edge_non_set{i}, bubble_size_non_set{i}]=single_bubble_track(bubble_area_set,0,0,gauss_blur);
   f=figure;
    f.PaperPosition=[1 1 17 8];
    subplot(2,3,1);
    hold all;
    plot(bubble_size_JN_set{i},'s');
    plot(bubble_size_GS_set{i},'d');
    plot(bubble_size_non_set{i},'o');
    subplot(2,3,2);
    bubble_JN=merge_cell_image_1D(bubble_edge_JN_set{i},1,2);
    imagesc(bubble_JN);
    axis image off
    colormap(gray);
    subplot(2,3,3);
    bubble_non=merge_cell_image_1D(bubble_edge_non_set{i},1,2);
    imagesc(bubble_non);
    axis image off
    colormap(gray);
    
    subplot(2,3,4);
    modified_area_big_image=...
        merge_cell_image_1D(bubble_edge_GS_set{i},1,2);
    imagesc(modified_area_big_image);
    axis image off
    colormap(gray);
    
    subplot(2,3,5);
    bubble_area_big_image=...
        merge_cell_image_1D(bubble_area_set,1,2);
    imagesc(bubble_area_big_image);
    axis image off
    colormap(gray);
    
    subplot(2,3,6);
    bubble_area_big_image_JN=...
        merge_cell_image_1D(bubble_area_set_JN,1,2);
    imagesc(bubble_area_big_image_JN);
    axis image off
    colormap(gray);
    
    print(f,'-dtiff', '-r300',...
        [folder,'/overall/bubble_',num2str(i),'.tiff']);
    close(f);
end

%% 40KV
start_point=30:2:length(bubble_size_rdf_set{ig})-20;
P_rdf=zeros(length(good_list),length(good_list));
for i=1:1:length(good_list)
    for j=1:1:length(start_point)
        %figure;
        ig=good_list(i);
        time_axis=time_axis_list(1:area_step:endframe);
        time_axis=time_axis';
        area_nm=bubble_size_rdf_set{ig}*scale_bar^2;
        P_rdf(i,j)=fit_exclude_outliers(time_axis(start_point(j):end),...
            area_nm(start_point(j):end),0,0,0);
    end
end
%% fit all those size curves 80kV
start_point=10:2:length(bubble_size_JN_set{1})-5;
P_JN=zeros(length(good_list),length(good_list));
for i=1:1:length(good_list)
    for j=1:1:length(start_point)
        %figure;
        ig=good_list(i);
        time_axis=time_axis_list(1:area_step:endframe);
        time_axis=time_axis;
        area_nm=bubble_size_JN_set{ig}*scale_bar^2;
        P_JN(i,j)=fit_exclude_outliers(time_axis(start_point(j):end),...
            area_nm(start_point(j):end),0,0,0);
    end
end

%% find the good ones
good_list=0;

%%
hold all
% time_axis=1:area_step:endframe;
% time_axis=(time_axis-1)*frame_time;
% time_axis=time_axis';
% or
time_axis=time_axis_list(1:area_step:endframe);
area_nm=bubble_size_rdf_set{11}*scale_bar^2;
exp=1;
plot(time_axis,area_nm.^exp,'o');
plot(time_axis_40,area_nm_40.^exp,'d-');
plot(time_axis_160,area_nm_160.^exp,'s-');

%%
cftool((time_axis_160(10:end)),(area_nm_160(10:end)));
%%
time_axis_40=time_axis;
area_nm_40=area_nm;
save 40kx_curve time_axis_40 area_nm_40

%%
time_axis_160=time_axis;
area_nm_160=area_nm;
save 160kx_curve time_axis_160 area_nm_160

%%
load 40kx_curve
load 160kx_curve

%%
param=zeros(length(good_list),2);
for i=1:1:1%length(good_list)
    area_nm=bubble_size_JN_set{good_list(i)}*scale_bar^2;
    param(i,:)=fit_growth_curve(time_axis,area_nm.^0.5,1);
end
%% use this function to get a bunch of circles, either blurred or not
ctemp_size=51;
circle_temps_diameter=0.2:0.2:25;
blur_list=[0.2:0.2:0.8 1:1:10];
%blur_list=0.8;
[circle_temps]=get_circle_templates(circle_temps_diameter,ctemp_size,blur_list);

%%
circle_big_image=merge_cell_image_1D(circle_temps,1,2);
imagesc(circle_big_image);
colormap(gray);
%%
hold all
imagesc(circle_matched{end});
plot(particle_position(:,2),particle_position(:,1),'ro-');
%%
JN_set=test_JN_parameters(bubble_area_set{5});
%% test which JN paramter works the best
single_bubble_track(JN_set,1);
%% looks like this section matters the most
diff_verbose=1;
diff_test=0;
diff_step=30;
bubble_size_diff=zeros(bubble_count,length(ImageFrames));
tophat_verbose=0;
tophat_test=0;
bubble_size_tophat=zeros(bubble_count,length(ImageFrames));
if ~exist([folder,'/outline'], 'dir')
    mkdir([folder,'/outline']);
end
for j=1:1:bubble_count
    % we will use different approaches to get particle size
    % and we will choose the one with largest area
    
    % the first approach uses the differential images
    % this approach works best with large growth speed
    if diff_test==1
        for i=length(ImageFrames):-10:diff_step+1
            bubble_sub=imcrop(ImageFrames{i}-ImageFrames{i-diff_step},...
                bubble_position{j});
            bubble_sub=imcrop(ImageFrames{i},...
                bubble_position{j});
            JN = CoherenceFilter(bubble_sub,struct('T',5,'rho',5,'Scheme','N','verbose','none'));
            JN = bubble_sub;
            %Edge5 =edge(JN,'Canny',0.5);
            Edge5 =edge(JN,'Canny',[0.05 0.2],3);
            Edge5=close_edges(Edge5,0);
            Edge5=imfill(Edge5,'holes');
            bubble_size_diff(j,i)=sum(Edge5(:));
            if(diff_verbose)
                f=figure;
                imshowpair(bubble_sub,Edge5);
                print(f,'-dtiff', '-r300',...
                    [folder,'/outline/bubble_',num2str(j),'diff_frame_',num2str(i),'.tiff']);
                close(f);
            end
        end
    end
    if diff_test == 0
        for i=1:step_size:length(ImageFrames)
            r=bubble_position{j};
            start_x=floor(r(1)+r(3)/2-max_width/2);
            start_y=floor(r(2)+r(4)/2-max_height/2);
            bubble_sub=imcrop(ImageFrames{i},...
                [start_x start_y max_width max_height]);JN = bubble_sub;
            JN=bubble_sub;
            Edge5 =edge(JN,'Canny',[0.05 0.2],3);
            Edge5 = imclose(Edge5, ones(5));
            Edge5=imfill(Edge5,'holes');
            bubble_size_diff(j,i)=sum(Edge5(:));
            bubble_area{j,i}=Edge5;
        end
    end
    % now the second approach, we can simply use tophat approach
    for i=1:10
    end
end

%%
hold all
plot(bubble_size_diff(1,:),'o');
plot(bubble_size_diff(2,:),'o');
plot(bubble_size_diff(3,:),'o');

%%
f=figure;
hold all
for i=1:1:bubble_count
    time=0:1:numel(bubble_size_diff(i,:))-1;
    [growth_rate{i},x_corrected{i},y_corrected{i}]=...
        fit_exclude_outliers(time,bubble_size_diff(i,:),500,[-2000 2000],1);
%     scatter(time,bubble_size_diff(i,:));
%     plot(time,time*growth_rate{i}(1)+growth_rate{i}(2));
end

%%
f=figure;
hold all
D=zeros(bubble_count,1);
t0=zeros(bubble_count,1);
for i=1:1:bubble_count
    scatter(x_corrected{i}*frame_time,...
        scale_bar*y_corrected{i}.^0.5);
    plot(frame_time*time,...
        scale_bar*(time*growth_rate{i}(1)+growth_rate{i}(2)).^0.5);
    C1=growth_rate{i}(1)*scale_bar^2/frame_time;
    C2=growth_rate{i}(2)*scale_bar^2;
    D(i)=sqrt(C1);
    t0(i)=C2/C1;
end
xlabel('time (s)');
ylabel('Average radius (nm)');
%% we want to get rid of the outliers for fitting
growth_rate{i}=fit_exclude_outliers(time,bubble_size_diff(8,:),500,...
    [-2000 2000],1);
%%

I_end=imcrop(ImageFrames{end-300},...
    bubble_position{3});
I1 = 2*I_end - imdilate(I_end, strel('square',15));

%%
I1(I1<0) = 0;
I1(I1>1) = 1;

I2 = imdilate(I1, strel('square',15)) - I1;
hautoth = vision.Autothresholder( ...
    'Operator', '<=', ...
    'ThresholdScaleFactor', 0.8);
I3=step(hautoth,I2);


I4 = 1-I3;
I_end_tophat = imtophat(I, strel('disk', 5));
Edge =edge(I4,'Canny',0.6,3);
imshowpair(Edge,I_end);
%close_edges(Edge);