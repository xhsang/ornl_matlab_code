%Particle size extracting
%writerObj = VideoWriter('ParticleGrowth_first.avi');
%writerObj.FrameRate = 10;
%writerObj.Duration=21;
%open(writerObj);

tic
data=DataFull;
width=size(DataFull, 2);
height=size(DataFull, 1);
nframes=size(DataFull,3);
cx=592; cy=385;
%Threshold area
x1=622; x2=697; y1=1; y2=75;

clear st

particles=[];
parms=[];
npi=[];
full_parms={};
search_data={};
boundary={};

for i=10:10%nframes;
    full_parms{i}=[];
    i
    frame=data(:,:,i);
    figure(2);
    clf;
    subplot(1,3,1);
    imagesc(frame);
    title(['Frame No' int2str(i)]);
    axis image;

    %Threasholding

    %threshold=max(max(frame(y1:y2, x1:x2)))*2.5;

    frame_bin=thresholding(frame, x1, x2, y1, y2);
    subplot(1,3,2);
    imagesc(frame_bin);
    axis image;


    [frame_c, parms, boundary{i}]=psearch(frame_bin,350);
    %search_data{i}=parms;
    part_num=size(parms,1);
    %tparms=[];

    if (size(particles,1)>0)
    npi=zeros(size(particles,1),1);
    extra_part=0;
    for j=1:size(particles,1)
        npi(j)=frame_c(particles(j,2), particles(j,1));
        if (npi(j)>0)
        full_parms{i}=[full_parms{i}; [npi(j) parms(npi(j), 2) parms(npi(j), 3) parms(npi(j), 1)]];
        else
        extra_part=extra_part+1
        full_parms{i}=[full_parms{i}; [part_num+extra_part, full_parms{i-1}(j,2:4)]];

        end    
    end
    end

    for j=1:part_num
        if isempty(find(npi==j))
            particles=[particles; [round(parms(j,2)) round(parms(j,3)) i]];
            full_parms{i}=[full_parms{i}; [j parms(j, 2) parms(j, 3) parms(j, 1)]];
        end
    end

    subplot(1,3,3); hold on
    imagesc(flipud(frame_c))
    %title(['Particles detected: ', int2str(part_num)]);
    axis image;
    caxis([0 part_num]);
    if (size(particles)>0) 
        plot(particles(:,1), height-particles(:,2)+1,'.w');
    end
    figure(2)
    set(2, 'Position', [100 300 1500 600])
    set(2, 'Renderer', 'zbuffer')
    %vf = getframe(2);
    %writeVideo(writerObj,vf);
    %close;


    if part_num>0
    dist=sqrt((parms(:,2)-cx).^2+(parms(:,3)-cy).^2);
    [mdist,p_i]=min(dist);
    st(i)=size(particles, 1);

    figure(3);
    plot(st, '.r');
    %plot_traces(full_parms, 1);
    %plot_part_surf(full_parms, boundary);

    end
end

%close(writerObj);

toc