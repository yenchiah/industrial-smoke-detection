function date = genDatestr( date_start,date_end )
    date_start = datetime(date_start,'Format','yyyy-MM-dd');
    date_end = datetime(date_end,'Format','yyyy-MM-dd');
    date_all = num2cell(date_start:date_end);
    date = cellfun(@datestrCell,date_all,'UniformOutput',false);
end

