function idx = binarySearchDatetime( target,time_array )
    min_idx = 1;
    max_idx = numel(time_array);
    date_min = datetime(time_array{min_idx},'TimeZone','America/New_York');
    date_max = datetime(time_array{max_idx},'TimeZone','America/New_York');
    while max_idx-min_idx > 1
        mid_idx = floor((min_idx+max_idx)/2);
        date_mid_EDT = datetime(time_array{mid_idx},'TimeZone','America/New_York');
        if(date_mid_EDT < target)
            min_idx = mid_idx;
            date_min = date_mid_EDT;
        else
            max_idx = mid_idx;
            date_max = date_mid_EDT;
        end
    end
    if(target-date_min <= date_max-target)
        idx = min_idx;
    else
        idx = max_idx;
    end
end

