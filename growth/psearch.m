function [member_mat, member_parms, member_b] = psearch(z, area_threshold)
%% SECTION TITLE
% DESCRIPTIVE TEXT
[m,n] = size(z);
z = [ zeros(1,n); z ; zeros(1,n) ];
[m,n] = size(z);
member_mat = zeros(m,n);
label = 1;

    offsets = [ -1; m ; 1 ; -m];

num_objects = 0;
%tic
for k1 = 1 : m
    for k2 = 1 : n
        if(z(k1,k2)==1)
            num_objects = num_objects+1;
            index = ((k2-1)*m+k1);
            member_mat(index) = label;
            while ~isempty(index)                
                z(index)=0;
                neighbors = bsxfun(@plus, index, offsets');
                neighbors(neighbors<1) = [];
                neighbors(neighbors>numel(z)) = [];
                neighbors = unique(neighbors(:));
                index = neighbors(1==(z(neighbors)));
                member_mat(index)=label;
            end
            label = label + 1;
        end
        
    end
end
member_mat(end,:) = [];
member_mat(1,:) = [];

area = zeros(size(label));
centroid_x = zeros(size(label));
centroid_y = zeros(size(label));
for k1 = 1 : label-1
    [x_loc,y_loc] = find(member_mat == k1);
    area(k1) = length(x_loc);
    if(area(k1)<area_threshold)
        area(k1) = nan;
        centroid_x(k1) = nan;
        centroid_y(k1) = nan;
        member_mat(x_loc,y_loc) = 0;
    else
        centroid_x(k1) = sum(x_loc)/area(k1);
        centroid_y(k1) = sum(y_loc)/area(k1);
    end    
end

ii=find(~isnan(area(:))==1);

if (label>1 && ~isempty(ii))
    for i=1:size(ii,1)
     b=bwboundaries(member_mat==ii(i));
     member_b{i}=b{1};
     
     member_mat(member_mat==ii(i))=i;
     
    end

    member_parms = [(area(ii))' (centroid_y(ii))' (centroid_x(ii))'];
else
    member_parms =[];
    member_b={};
    member_mat=[];
end

end