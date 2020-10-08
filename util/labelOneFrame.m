function labelOneFrame( t,num_frames,data_mat,label_mat,has_label_mat )
    set(gca,'position',[0 0 1 1]);
    ROI = roipoly(squeeze(data_mat.data(:,:,:,t)));
    if(numel(ROI)~=0)
        fprintf('Frame %d / %d saved\n',t,num_frames);
        label_mat.label(:,:,:,t) = ROI;
        has_label_mat.has_label(:,t) = true;
    end
    showOneFrame(t,num_frames,data_mat,label_mat,has_label_mat);
end

