function fileList = searchFiles( dirName,searchStr )
    fileList = {};
    files = getAllFiles(dirName);
    for i=1:length(files)
        k = strfind(files{i}, searchStr);
        if(~isempty(k))
            fileList{end+1} = files{i};
        end
    end
    fileList = fileList';
end

