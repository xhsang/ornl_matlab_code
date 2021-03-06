%%
count=1;
for angle=0:10:0
    r_x=particle_position(i,1)+r*cosd(angle);
    r_y=particle_position(i,2)+r*sind(angle);
    if 1
        f=figure;
        subplot(2,2,1);
        hold all
        imagesc(bubble_area_set{i});
        colormap(gray);
        plot(r_y,r_x,'wo');
        axis image;
        subplot(2,2,2);
        [cx,cy,c]=improfile(temp1,r_y,r_x);
        plot(r,c,'-o');
        subplot(2,2,3);
        plot(r(1:end-1),diff(c),'-o');
        subplot(2,2,4);
        [V,I]=min(diff(c));
        hold all
        imagesc(bubble_area_set{i});
        colormap(gray);
        plot(r_y(I+1),r_x(I+1),'or');


        
        print(f,'-dtiff', '-r300', [folder,'/particle_enhanced_edge/frame',num2str(angle),'.tiff']);
        close(f);
    end
    edgex(count)=r_x(I+1);
    edgey(count)=r_y(I+1);
    count=count+1;
end



%%
i=13
hold all
imagesc(bubble_area_set{i});
colormap(gray);
axis image;

%%

[sizex,sizey]=size(bubble_area_set{i});
[gridx,gridy]=meshgrid(1:sizey,1:sizex);
gridr=sqrt((gridx-particle_position(i,2)).^2+...
    (gridy-particle_position(i,1)).^2);
rdf_R=ceil(max(gridr(:)));
rdf_count=zeros(rdf_R,1);
rdf=zeros(rdf_R,1);
for p=1:1:sizex
    for q=1:1:sizey
        rdf(ceil(gridr(p,q)))=rdf(ceil(gridr(p,q)))+bubble_area_set{i}(p,q);
        rdf_count(ceil(gridr(p,q)))=rdf_count(ceil(gridr(p,q)))+1;
    end
end
rdf=rdf./rdf_count;
plot(rdf)

%% try to peak fit the rdf
[xData, yData] = prepareCurveData( 1:1:length(rdf), rdf );

ft = fittype( 'a1*exp(-((x-b1)/c1)^2)+d1', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [max(rdf)-min(rdf) particle_radius(i) 2 min(rdf)];

[fitresult, gof] = fit( xData, yData, ft, opts );

rdf_gauss=fitresult(xData);
rdf_gauss=rdf_gauss-min(rdf_gauss);
rdf_map{i}=rdf_gauss(ceil(gridr));
imagesc(rdf_map{i});

%%
[min(rdf) max(rdf)]

gridtheta=atan2d(gridy-particle_position(i,1),gridx-particle_position(i,2));
y_filter=1./(yfilt-min(yfilt)+10);
y_filter=max(y_filter)*0+y_filter;
rdf_map{i}=(rdf(ceil(gridr))-min(rdf)).*y_filter(ceil(gridtheta/10+18));
imagesc((rdf_map{i}+max(rdf_map{i}(:))).*bubble_area_set{i});
%% tangential direction
i=5;
angle=-720:10:720;
r_x=particle_position(i,1)+particle_radius(i)*cosd(angle);
r_y=particle_position(i,2)+particle_radius(i)*sind(angle);
[cx,cy,c]=improfile(bubble_area_set{i},r_y,r_x,length(r_y));
plot(angle,c,'o-');
hold all
plot(angle,c./c*(min(c)+(mean(c)-min(c))*0.5),'k-');
%%
hold on;
imagesc(bubble_area_set{i});
colormap(gray)
plot(r_y(10),r_x (10),'xr','markersize',10);
set(gca,'Ydir','reverse');
axis image

%%
gridtheta=atan2d(gridx-particle_position(i,2),gridy-particle_position(i,1));
gridtheta(gridtheta<0)=gridtheta(gridtheta<0)+360;
imagesc(gridtheta);
%%
sigma = 3;
gsize = 30;
x = linspace(-gsize / 2, gsize / 2, gsize);
gaussFilter = exp(-x .^ 2 / (2 * sigma ^ 2));
gaussFilter = gaussFilter / sum (gaussFilter);
yfilt = conv (c, gaussFilter, 'same');
yfilt=yfilt(72:108);
plot(yfilt);

%%
y_filter=1./(yfilt);
y_filter=y_filter-min(y_filter);
angle1=0:10:360;
y_fiter_fit=fit(angle1',y_filter,'smoothingspline');
y_filter_fine=y_fiter_fit(0:1:360);

t_map{i}=y_filter_fine(max(ceil(gridtheta),1));
imagesc(t_map{i});
axis image
%plot(-180:10:180,c(18:54));
%%
imagesc(t_map{i}.*rdf_map{i});
axis image
%%
plot(edgey,edgex,'or-');
%%
[cx,cy,c]=improfile(temp1,r_y,r_x);
plot(r,c,'o');

i=21;
temp1=bubble_area_set{i};
temp2=circle_matched{i};
rad_range=particle_radius(i)*1.5/2;
r=round(particle_radius(i)-rad_range:1:particle_radius(i)+rad_range);
