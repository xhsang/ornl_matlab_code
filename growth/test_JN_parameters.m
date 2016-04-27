% this function tests the best JN value

function JN_set=test_JN_parameters(bubble_image)
f=figure;
p=5;
count=1;
for i=5:1:5
    for j=1:1:25
        subplot(p,p,count);
        JN=CoherenceFilter(bubble_image,struct('T',i,'rho',j/10,'Scheme','N'));
        imagesc(JN);
        JN_set{count}=JN;
        axis off image
        count=count+1;
    end
end
end