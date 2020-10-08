function [ seg_start,seg_end,seg ] = mergeSegments( seg_start_raw,seg_end_raw,seg_raw )
    thr = 30;
    seg_start = [];
    seg_end = [];
    seg = seg_raw;
    while numel(seg_start_raw)>1
        if(seg_start_raw(2)-seg_end_raw(1)<thr)
            seg(seg_end_raw(1):seg_start_raw(2)) = 1;
            seg_end_raw(1) = seg_end_raw(2);
            seg_start_raw(2) = [];
            seg_end_raw(2) = [];
        else
            seg_start(end+1) = seg_start_raw(1);
            seg_end(end+1) = seg_end_raw(1);
            seg_start_raw(1) = [];
            seg_end_raw(1) = [];
        end
    end
    if(numel(seg_start_raw)>=1)
        seg_start(end+1) = seg_start_raw(1);
        seg_end(end+1) = seg_end_raw(1);
    end
end

