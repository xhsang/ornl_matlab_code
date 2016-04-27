function [modified_particle_area,rdf_map]=...
    modify_bubble_area_from_circles(filename,bubble_area,...
    circle_matched,particle_position,particle_radius,verbose)

N=length(bubble_area);

[folder,name,ext] = fileparts(filename);

if ~exist([folder,'/particle_enhanced_edge'], 'dir')
    mkdir([folder,'/particle_enhanced_edge']);
end

sigma = 3;
gsize = 30;
x = linspace(-gsize / 2, gsize / 2, gsize);
gaussFilter = exp(-x .^ 2 / (2 * sigma ^ 2));
gaussFilter = gaussFilter / sum (gaussFilter);


% use the angular distribution to enhance it self
for i=1:1:N
    [sizex,sizey]=size(bubble_area{i});
    [gridx,gridy]=meshgrid(1:sizey,1:sizex);
    gridr=sqrt((gridx-particle_position(i,2)).^2+...
        (gridy-particle_position(i,1)).^2);
    rdf_R=ceil(max(gridr(:)));
    rdf_count=zeros(rdf_R,1);
    rdf=zeros(rdf_R,1);
    for p=1:1:sizex
        for q=1:1:sizey
            rdf(ceil(gridr(p,q)))=rdf(ceil(gridr(p,q)))+bubble_area{i}(p,q);
            rdf_count(ceil(gridr(p,q)))=rdf_count(ceil(gridr(p,q)))+1;
        end
    end
    rdf=rdf./rdf_count;
    
    angle=-180:10:540;
    r_x=particle_position(i,1)+particle_radius(i)*cosd(angle);
    r_y=particle_position(i,2)+particle_radius(i)*sind(angle);
    [cx,cy,c]=improfile(bubble_area{i},r_y,r_x,length(r_y));
    yfilt = conv (c, gaussFilter, 'same');
    yfilt=yfilt(18:54);
    gridtheta=atan2d(gridy-particle_position(i,1),gridx-particle_position(i,2));
    y_filter=1./(yfilt-min(yfilt)+10);
    y_filter=max(y_filter)*0+y_filter;
    rdf_map{i}=(rdf(ceil(gridr))-min(rdf)).*y_filter(ceil(gridtheta/10+18));
    
    
    %plot(rdf);
    % then create a new map with the calculated RDF
    rdf_map{i}=rdf(ceil(gridr));
    if verbose == 1
        f=figure;
        E=rdf_map{i}.*bubble_area{i};
        Edge0=E;
        Edge =edge(Edge0 ,'Canny',[0.05 0.2],2);
        Edge1 = bwareafilt(Edge,1);
        %Edge5=JN1{i_count,j_count} ;
        Edge2 = imclose(Edge1, ones(4));
        
        subplot(1,2,1);
        hold all
        imagesc(E);
        colormap(gray);
        [row,col,v] = find(Edge2);
        plot(col,row,'xr');
        axis image
        
        Edge0=bubble_area{i};
        Edge =edge(Edge0 ,'Canny',[0.05 0.2],2);
        Edge1 = bwareafilt(Edge,1);
        %Edge5=JN1{i_count,j_count} ;
        Edge2 = imclose(Edge1, ones(4));
        
        subplot(1,2,2);
        hold all
        imagesc(bubble_area{i});
        axis image
        colormap(gray);
        [row,col,v] = find(Edge2);
        plot(col,row,'xr');
        print(f,'-dtiff', '-r300', [folder,'/particle_enhanced_edge/frame',num2str(i),'.tiff']);
        close(f);
    end
    modified_particle_area{i}=rdf_map{i}.*bubble_area{i};
end
end


