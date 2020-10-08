function stat = describeDistribution( f,x )
    min_peak_prominence = 0.05;
    min_peak_height = 2;
    [pks,locs,~,~] = findpeaks(f,'MinPeakProminence',min_peak_prominence,'MinPeakHeight',min_peak_height);
    if(numel(pks)==0)
        x_max = 0;
        pks_max = 0;
    else
        [pks_max, idx_max] = max(pks);
        locs_max = locs(idx_max);
        x_max = x(locs_max);
    end
    
    stat = [x_max,pks_max,numel(pks),mean(f),median(f),var(f)];
end

