function [fscore,predict] = computeFscore( label_raw,predict_raw )
    [label_start_raw,label_end_raw] = computeSegments(label_raw);
    [predict_start_raw,predict_end_raw] = computeSegments(predict_raw);
    
    % merge unreasonable labels
    [label_start,label_end,label] = mergeSegments(label_start_raw,label_end_raw,label_raw);
    [predict_start,predict_end,predict] = mergeSegments(predict_start_raw,predict_end_raw,predict_raw);

    % compute true positives and false positives
    % (FP) the segment is smaller than 240 and no predictons in a segment are true labels
    % (FP) the segment is larger than 240 and less than 30% of the predictons in a segment are true labels
    TP = 0;
    FP = 0;
    predict_tmp = predict;
    for i=1:numel(predict_start)
        idx = predict_start(i):predict_end(i);
        idx_num = numel(idx);
        if(sum(label(idx))==0 || (idx_num>240 && sum(label(idx))/idx_num<0.3))
            FP = FP + 1;
            predict_tmp(idx) = 0;
        else
            TP = TP + 1;
        end
    end
    
    % compute false negatives
    FN = 0;
    for i=1:numel(label_start)
        idx = label_start(i):label_end(i);
        if(sum(predict_tmp(idx))==0)
            FN = FN + 1;
        end
    end

    % compute f-score
    precision = TP/(TP+FP);
    recall = TP/(TP+FN);
    score = (2*precision*recall)/(precision+recall);
    
    fscore.TP = TP;
    fscore.FP = FP;
    fscore.FN = FN;
    fscore.precision = precision;
    fscore.recall = recall;
    fscore.score = score;
end

