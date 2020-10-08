function showOneFrame( t,num_frames,data_mat,label_mat,has_label_mat,label_predict_mat,data_median_mat,bbox_row,bbox_col )
    narginchk(5,9);
    set(gca,'position',[0 0 1 0.97]);
    if(nargin == 5)
        data = squeeze(data_mat.data(:,:,:,t));
        label = squeeze(label_mat.label(:,:,:,t));
        has_label = has_label_mat.has_label(:,t);
        imshow(imfuse(data,imfuse(data,label),'montage'))
        title(sprintf('Viewing frame %d / %d , hasLabel = %d \n (press ENTER to label this frame, ESC to exit when labeling, DELETE to delete the label)',t,num_frames,has_label))
    elseif(nargin == 9)
        data = squeeze(data_mat.data(bbox_row,bbox_col,:,t));
        label = squeeze(label_mat.label(bbox_row,bbox_col,:,t));
        has_label = has_label_mat.has_label_predict(:,t);
        label_predict = squeeze(label_predict_mat.label_predict(:,:,:,t));
        data_median = squeeze(data_median_mat.median(bbox_row,bbox_col,:,t));
        subplot(2,2,1)
        imshow(data)
        title(sprintf('Viewing frame %d / %d , hasLabel = %d',t,num_frames,has_label))
        subplot(2,2,2)
        imshow(data_median)
        subplot(2,2,3)
        imshow(imfuse(data,label))
        subplot(2,2,4)
        imshow(imfuse(data,label_predict))
    end
    fprintf('Viewing frame %d / %d , hasLabel = %d\n',t,num_frames,has_label);
end