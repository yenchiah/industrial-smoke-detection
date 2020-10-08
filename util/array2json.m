function js = array2json( vec,predict_raw )
    % encode vector
    js = ['var smoke_detection = {values:',array2Str(vec),'};'];
    % encode prediction
    [frames_start_raw,frames_end_raw] = computeSegments(predict_raw);
    [frames_start,frames_end,~] = mergeSegments(frames_start_raw,frames_end_raw,predict_raw);
    js = [js,'var frames_start = ',array2Str(frames_start),';'];
    js = [js,'var frames_end = ',array2Str(frames_end),';'];
end

