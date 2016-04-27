function circle_temps=get_circle_templates(...
    circle_size,ctemp_size,blur_list)
for m=1:1:length(blur_list)
    blur=blur_list(m);
    for k=1:1:length(circle_size)
        centerx=(ctemp_size+1)/2;
        centery=(ctemp_size+1)/2;
        circle_temps{k,m}=zeros(ctemp_size,ctemp_size);
        for i=1:1:ctemp_size
            for j=1:1:ctemp_size
                d=sqrt((i-centerx)^2+(j-centery)^2);
                %if round(d-circle_size(k))==0
                %    circle_temps{k}(i,j)=1;
                %end
                circle_temps{k,m}(i,j)=exp(-((d-circle_size(k))^2/blur^2));
            end
        end
        %circle_temps{k}=imgaussfilt(circle_temps{k},blur);
    end
end
end