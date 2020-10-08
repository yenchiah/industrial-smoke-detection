function str = array2Str( arr )
    str = '[';
    L = numel(arr);
    for i=1:L
        str = [str,num2str(arr(i))];
        if(i~=L)
            str = [str,','];
        else
            str = [str,']'];
        end
    end
end

