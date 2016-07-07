function [Ps, x_corrected,y_corrected]=fit_exclude_outliers(y,x,threshold,x0_range,verbose)

x_slope=NaN(numel(x),numel(x));
x_slope_bk=x_slope;
x_x0=NaN(numel(x),numel(x));
x_x0_bk=x_x0;
for i=1:1:length(x)
    if x(i) == 0
        continue;
    end
    for j=i+1:1:length(x)
        if x(j) == 0
            continue;
        end
        x_slope(i,j)=(x(j)-x(i))/(y(j)-y(i));
        x_x0(i,j)=x(i)-x_slope(i,j)*y(i);
        x_slope_bk(i,j)=x_slope(i,j);
        x_slope_bk(j,i)=x_slope(i,j);
        x_x0_bk(i,j)=x_x0(i,j);
        x_x0_bk(j,i)=x_x0(i,j);
    end
end

x_slope=x_slope(~isnan(x_slope));
x_slope_r=min(x_slope):1:max(x_slope);
x_slope_h=hist(x_slope,x_slope_r);
if verbose~=0
    subplot(2,3,1);
    plot(x_slope_r,x_slope_h);
end
x_x0=x_x0(~isnan(x_x0));
max_x_x0=max(x_x0);
min_x_x0=min(x_x0);

if numel(x0_range)==2
    max_x_x0=x0_range(2);
    min_x_x0=x0_range(1);
end
step=(max_x_x0-min_x_x0)/1000;
x_x0_r=min(x_x0):step:max(x_x0);
x_x0_h=hist(x_x0,x_x0_r);
if verbose~=0
    subplot(2,3,2);
    plot(x_x0_r,x_x0_h);
    xlim([min_x_x0 max_x_x0]);
end

% now we need to find the most popular x0 and k
[x_slope_max,x_slope_index]=max(x_slope_h);
[x_x0_max,x_x0_index]=max(x_x0_h);
x0=x_x0_r(x_x0_index);
k=x_slope_r(x_slope_index);

x_predicted=y*k+x0;

if verbose~=0
    subplot(2,3,3);
    hold all;
    plot(y,x,'o');
    plot(y,x_predicted);
end

% apparently this is not enough, 
% we need to fit the curve using useful datapoints

distance=abs(x_predicted-x);
if verbose~=0
    subplot(2,3,4);
    hold on;
    plot(distance,'o');
    ylim([0 max(distance)]);
    plot((distance./distance)*mean(distance));
    plot((distance./distance)*mean(distance)*3);
end

if threshold==0
    threshold=mean(distance)+3*std(distance);
end

x_corrected=y(distance<threshold&x~=0);
y_corrected=x(distance<threshold&x~=0);
P = polyfit(x_corrected,y_corrected,1);
if verbose~=0
    subplot(2,3,6);
    hold all
    plot(x_corrected,y_corrected,'o');
    plot(y,P(2)+y*P(1))
end
Ps=P(1);
end