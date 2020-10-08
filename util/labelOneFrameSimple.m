function labelOneFrameSimple( t,num_frames,data_mat,label_simple_mat,class )
    set(gca,'position',[0 0 1 1]);
    label_simple_mat.label_simple(:,t) = uint8(class);
    showOneFrameSimple(t,num_frames,data_mat,label_simple_mat);
end

