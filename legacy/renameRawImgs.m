clear all;
addpath(genpath('libs'));
addpath(genpath('util'));

% set data source
target_dir = 'images/';
date_path = '2015-05-02/';
path = fullfile(target_dir,date_path);

% scan file numbers
fprintf('Count the number of files\n');
file_num = 0;
list = dir(path);
for i=1:numel(list)
    if(~list(i).isdir)
        file_num = file_num + 1;
    end
end

% read files
format = 'dd-mmm-yyyy HH:MM:SS';
file_paths = cell(file_num,1);
file_mod_dates = zeros(file_num,1,'uint64');
file_pt = 1;
for i=1:numel(list)
    fprintf('Process file %d\n',i);
    filename = list(i).name;
    if(~list(i).isdir)
        file = fullfile(path,filename);
        info = imfinfo(file);
        file_paths{file_pt} = file;
        file_mod_dates(file_pt) = uint64(datenum(info.FileModDate,format)*24*60*60);
        file_pt = file_pt + 1;
    end
end

% sort date and rename files
[sorted,idx] = sort(file_mod_dates);
for j=1:numel(idx)
    fprintf('Rename file %d\n',j);
    file_origin = fullfile(file_paths{idx(j)});
    file_move = fullfile(path,[num2str(j),'.jpg']);
    if(~strcmp(file_origin,file_move))
        movefile(fullfile(file_paths{idx(j)}),fullfile(path,[num2str(j),'.jpg']));
    end
end