%%
i=11;
I5=ImageFrames{i+30}-ImageFrames{i};
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
imshowpair(Edge5,ImageFrames{i+30}(read_rangex,read_rangey));

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
    imshowpair(read_area,Edge5);
    
    print(f,'-dtiff', '-r300', [folder,'/outline/frame',num2str(i),'.tiff']);
    close(f);
end



%%
bubble_count=0;
%% select multiple areas
figure
imagesc(ImageFrames{end});
axis image
colormap(gray);
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

%% or easily find them
%% looks like this section matters the most
diff_verbose=1;
diff_test=1;
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
            JN = CoherenceFilter(bubble_sub,struct('T',5,'rho',5,'Scheme','N','verbose','none'));
            Edge5 =edge(JN,'Canny',0.5);
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
    
    % now the second approach, we can simply use tophat approach
    for i=1:10
    end
end

%%
hold all
plot(bubble_size_diff(1,:),'o');
plot(bubble_size_diff(2,:),'o');
plot(bubble_size_diff(3,:),'o');

%% we want to get rid of the outliers for fitting
load moore
X = [moore(:,1:5)];
y = moore(:,6);

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