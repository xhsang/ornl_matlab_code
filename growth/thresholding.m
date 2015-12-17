function [frame_bin] = thresholding(frame, bx1, bx2, by1, by2)
    blevel=double(max(max(frame(by1:by2, bx1:bx2))));
    mlevel=double(max(max(frame)));
    
    threshold=(blevel+mlevel)/27;
    frame_bin=(frame>threshold);
    
%     figure(2);
%     clf;
%     subplot(1,2,1);
%     imagesc(frame);
%     axis image;
%     subplot(1,2,2);
%     imagesc(frame_bin);
%     axis image;
    
    
end
