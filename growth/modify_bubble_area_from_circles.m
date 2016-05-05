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
    if particle_radius
    end
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
    [xData, yData] = prepareCurveData( 1:1:length(rdf), rdf );
    
    ft = fittype( 'a1*exp(-((x-b1)/c1)^2)+d1', 'independent', 'x', 'dependent', 'y' );
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Display = 'Off';
    opts.StartPoint = [max(rdf)-min(rdf) particle_radius(i) 2 min(rdf)];
    [fitresult, gof] = fit( xData, yData, ft, opts );
    rdf_gauss=fitresult(xData);
    rdf_gauss=rdf_gauss-min(rdf_gauss);
    
    angle=-720:10:720;
    r_x=particle_position(i,1)+particle_radius(i)*cosd(angle);
    r_y=particle_position(i,2)+particle_radius(i)*sind(angle);
    [cx,cy,c]=improfile(bubble_area{i},r_y,r_x,length(r_y));
    yfilt = conv (c, gaussFilter, 'same');
    yfilt=yfilt(72:108);
    
    gridtheta=atan2d(gridx-particle_position(i,2),gridy-particle_position(i,1));
    gridtheta(gridtheta<0)=gridtheta(gridtheta<0)+360;
    
    y_filter=1./(yfilt);
    y_filter=y_filter-min(y_filter);
    angle1=0:10:360;
    y_fiter_fit=fit(angle1',y_filter,'smoothingspline');
    y_filter_fine=y_fiter_fit(0:1:360);
    
    t_map{i}=y_filter_fine(max(ceil(gridtheta),1));    
    
    %plot(rdf);
    % then create a new map with the calculated RDF
    rdf_map{i}=rdf_gauss(ceil(gridr)).*t_map{i};
    rdf_map{i}=rdf_map{i}/max(rdf_map{i}(:));
    if verbose == 1
        f=figure;
        
        subplot(2,2,1);
        imagesc(rdf_map{i});
        colormap(gray);
        
        subplot(2,2,2);
        imagesc((rdf_map{i}+1).*bubble_area{i});
        colormap(gray);
        
        E=(rdf_map{i}+1).*bubble_area{i};
        Edge0=E;
        Edge =edge(Edge0 ,'Canny',[0.05 0.2],2);
        Edge1 = bwareafilt(Edge,1);
        %Edge5=JN1{i_count,j_count} ;
        Edge2 = imclose(Edge1, ones(4));
        
        subplot(2,2,3);
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
        
        subplot(2,2,4);
        hold all
        imagesc(bubble_area{i});
        axis image
        colormap(gray);
        [row,col,v] = find(Edge2);
        plot(col,row,'xr');
        print(f,'-dtiff', '-r300', [folder,'/particle_enhanced_edge/frame',num2str(i),'.tiff']);
        close(f);
    end
    modified_particle_area{i}=(rdf_map{i}+1).*bubble_area{i};
end
end


