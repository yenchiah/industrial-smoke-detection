function keyDownListenerShowData( src,event,num_frames,data_mat,label_mat,has_label_predict_mat,has_label_predict_idx,show_has_label_predict_only,label_predict_mat,data_median_mat,bbox_row,bbox_col )
    global t
    if(strcmp(event.Key,'rightarrow'))
        if(show_has_label_predict_only==0 && t<num_frames)
            t = t + 1;
            showOneFrame(t,num_frames,data_mat,label_mat,has_label_predict_mat,label_predict_mat,data_median_mat,bbox_row,bbox_col);
        elseif(show_has_label_predict_only==1 && t<has_label_predict_idx(end))
            next = find(has_label_predict_idx>t);
            t = has_label_predict_idx(next(1));
            showOneFrame(t,num_frames,data_mat,label_mat,has_label_predict_mat,label_predict_mat,data_median_mat,bbox_row,bbox_col);
        end
    elseif(strcmp(event.Key,'leftarrow'))
        if(show_has_label_predict_only==0 && t>1)
            t = t - 1;
            showOneFrame(t,num_frames,data_mat,label_mat,has_label_predict_mat,label_predict_mat,data_median_mat,bbox_row,bbox_col);
        elseif(show_has_label_predict_only==1 && t>has_label_predict_idx(1))
            previous = find(has_label_predict_idx<t);
            t = has_label_predict_idx(previous(end));
            showOneFrame(t,num_frames,data_mat,label_mat,has_label_predict_mat,label_predict_mat,data_median_mat,bbox_row,bbox_col);
        end
    end
end