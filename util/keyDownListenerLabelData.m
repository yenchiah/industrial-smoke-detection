function keyDownListenerLabelData( src,event,num_frames,data_mat,label_mat,has_label_mat,has_label_idx,show_has_label_only )
    global t
    if(strcmp(event.Key,'rightarrow'))
        if(show_has_label_only==0 && t<num_frames)
            t = t + 1;
            showOneFrame(t,num_frames,data_mat,label_mat,has_label_mat);
        elseif(show_has_label_only==1 && t<has_label_idx(end))
            next = find(has_label_idx>t);
            t = has_label_idx(next(1));
            showOneFrame(t,num_frames,data_mat,label_mat,has_label_mat);
        end
    elseif(strcmp(event.Key,'leftarrow'))
        if(show_has_label_only==0 && t>1)
            t = t - 1;
            showOneFrame(t,num_frames,data_mat,label_mat,has_label_mat);
        elseif(show_has_label_only==1 && t>has_label_idx(1))
            previous = find(has_label_idx<t);
            t = has_label_idx(previous(end));   
            showOneFrame(t,num_frames,data_mat,label_mat,has_label_mat);
        end
    elseif(strcmp(event.Key,'return'))
        labelOneFrame(t,num_frames,data_mat,label_mat,has_label_mat);
    elseif(strcmp(event.Key,'delete'))
        deleteLabelOneFrame(t,num_frames,data_mat,label_mat,has_label_mat);
    end
end