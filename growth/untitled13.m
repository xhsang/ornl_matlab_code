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
%plot(rdf)
[min(rdf) max(rdf)]

gridtheta=atan2d(gridy-particle_position(i,1),gridx-particle_position(i,2));
y_filter=1./(yfilt-min(yfilt)+10);
y_filter=max(y_filter)*0+y_filter;
rdf_map{i}=(rdf(ceil(gridr))-min(rdf)).*y_filter(ceil(gridtheta/10+18));
imagesc((rdf_map{i}+max(rdf_map{i}(:))).*bubble_area_set{i});
%% tangential direction
i=5;
angle=-180:10:540;
r_x=particle_position(i,1)+particle_radius(i)*cosd(angle);
r_y=particle_position(i,2)+particle_radius(i)*sind(angle);
[cx,cy,c]=improfile(bubble_area_set{i},r_y,r_x,length(r_y));
plot(angle,c,'o-');
hold all
plot(angle,c./c*(min(c)+(mean(c)-min(c))*0.5),'k-');
%%
sigma = 3;
gsize = 30;
x = linspace(-gsize / 2, gsize / 2, gsize);
gaussFilter = exp(-x .^ 2 / (2 * sigma ^ 2));
gaussFilter = gaussFilter / sum (gaussFilter);
yfilt = conv (c, gaussFilter, 'same');
yfilt=yfilt(18:54);
plot(-180:10:180,1./(yfilt-min(yfilt)+10));
hold on;
%plot(-180:10:180,c(18:54));
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
