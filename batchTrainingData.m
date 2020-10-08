tic
clear all;
addpath(genpath('libs'));
addpath(genpath('util'));
warning('off','all')

date = {
    '2015-05-01','2015-05-02','2015-05-03',...
    '2015-05-04','2015-05-05','2015-05-06','2015-05-07','2015-05-08','2015-05-09',...
    '2015-04-02','2015-05-28','2015-06-11','2015-07-08','2015-08-13','2015-09-09','2015-10-05','2015-11-15',...
    '2015-04-13','2015-05-15','2015-06-15','2015-07-26','2015-08-24','2015-09-19','2015-10-19','2015-11-26'};

output_label = false;

% read mask
target_dir = 'frames';
dataset_path = 'crf26-12fps-1424x800/';
tile_path = '1/2/2.mp4';
fprintf('Loading bbox.mat\n');
load(fullfile(target_dir,'bbox.mat'));

% tile information
[~,num_tiles] = img2Tiles();

% find positive and negative label idx
label_pos_idx = cell(numel(date),1);
label_neg_idx = cell(numel(date),1);
tile_pos_count = zeros(numel(date),1);
tile_neg_count = zeros(numel(date),1);
for idx=1:numel(date)
    fprintf('Find label idx of date %s\n',date{idx});
    % set data source
    date_path = [date{idx},'.timemachine/'];
    path = fullfile(target_dir,date_path,dataset_path,tile_path);
    % read ground truth labels
    load(fullfile(path,'label_simple.mat'));
    % read prediction
    load(fullfile(path,'label_predict.mat'));
    % read sum frames
    load(fullfile(path,'sun_frame.mat'));
    % find frames having positive labels
    true_label_idx = find(label_simple>1);
    num_true_label_idx = numel(true_label_idx);
    for i=1:num_true_label_idx
        tile_predict = img2Tiles(label_predict(:,:,1,true_label_idx(i)));
        is_smoke_tile = cell2mat(cellfun(@findSmokeTile,tile_predict,'UniformOutput',false));
        smoke_tiles = find(is_smoke_tile==1);
        if(numel(smoke_tiles)>0)
            tile_pos_count(idx) = tile_pos_count(idx) + numel(smoke_tiles);
            label_pos_idx{idx}(end+1,:) = {true_label_idx(i),smoke_tiles};
        end
    end
    % find frames having negative labels
    false_label_idx = find(label_simple==0);
    false_label_idx(false_label_idx<sunrise_frame) = [];
    false_label_idx(false_label_idx>sunset_frame) = [];
    num_false_label_idx = numel(false_label_idx);
    step = round(num_false_label_idx/num_true_label_idx*5);
    for i=1:step:num_false_label_idx
        tile_neg_count(idx) = tile_neg_count(idx) + num_tiles;
        label_neg_idx{idx}(end+1,:) = {false_label_idx(i),1:num_tiles};
    end
end

if(output_label) 
    % create workers
    try
        fprintf('Closing any pools...\n');
        delete(gcp('nocreate'));
    catch ME
        disp(ME.message);
    end
    local_cluster = parcluster('local');
    num_workers = 3;
    if(local_cluster.NumWorkers > num_workers + 1)
        num_workers = local_cluster.NumWorkers;
    end
    if(num_workers>12)
        num_workers = 12;
    end
    parpool('local',num_workers);
    
    % allocate space
    label_pos = cell(numel(date),1);
    label_pos_pre = cell(numel(date),1);
    label_pos_pre2 = cell(numel(date),1);
    label_pos_bg = cell(numel(date),1);
    label_neg = cell(numel(date),1);
    label_neg_pre = cell(numel(date),1);
    label_neg_pre2 = cell(numel(date),1);
    label_neg_bg = cell(numel(date),1);

    % process dates
    for idx = 1:numel(date)
        % set data source
        date_path = [date{idx},'.timemachine/'];
        % read frames
        fprintf('Read images of date %s\n',date{idx});
        path = fullfile(target_dir,date_path,dataset_path,tile_path);
        data_mat = matfile(fullfile(path,'data.mat'));
        data_median_mat = matfile(fullfile(path,'data_median_60.mat'));
        % initialize positive tiles
        fprintf('Compute pos images of date %s\n',date{idx});
        cell_size = size(label_pos_idx{idx},1);
        img_pos = cell(cell_size,1);
        img_pos_bg = cell(cell_size,1);
        img_pos_pre = cell(cell_size,1);
        img_pos_pre2 = cell(cell_size,1);
        % construct positive tiles
        parfor k = 1:size(label_pos_idx{idx},1)
            frame_num = label_pos_idx{idx}{k,1};
            fprintf('Process pos frame %d of date %s\n',frame_num,date{idx});
            tile_idx = label_pos_idx{idx}{k,2};
            tile = img2Tiles(data_mat.data(bbox_row,bbox_col,:,frame_num));
            tile_pre = img2Tiles(data_mat.data(bbox_row,bbox_col,:,frame_num-1));
            tile_pre2 = img2Tiles(data_mat.data(bbox_row,bbox_col,:,frame_num-2));
            tile_bg = img2Tiles(data_median_mat.median(bbox_row,bbox_col,:,frame_num));
            img_pos{k} = tile(tile_idx);
            img_pos_pre{k} = tile_pre(tile_idx);
            img_pos_pre2{k} = tile_pre2(tile_idx);
            img_pos_bg{k} = tile_bg(tile_idx);
        end
        % cat positive images
        img_pos = cat(1,img_pos{:});
        img_pos = cat(4,img_pos{:});
        img_pos_pre = cat(1,img_pos_pre{:});
        img_pos_pre = cat(4,img_pos_pre{:});
        img_pos_pre2 = cat(1,img_pos_pre2{:});
        img_pos_pre2 = cat(4,img_pos_pre2{:});
        img_pos_bg = cat(1,img_pos_bg{:});
        img_pos_bg = cat(4,img_pos_bg{:});
        % save positive images
        label_pos{idx} = img_pos;
        label_pos_pre{idx} = img_pos_pre;
        label_pos_pre2{idx} = img_pos_pre2;
        label_pos_bg{idx} = img_pos_bg;
        % initialize negtive tiles
        fprintf('Compute neg images of date %s\n',date{idx});
        cell_size = size(label_neg_idx{idx},1);
        img_neg = cell(cell_size,1);
        img_neg_bg = cell(cell_size,1);
        img_neg_pre = cell(cell_size,1);
        img_neg_pre2 = cell(cell_size,1);
        % construct negtive tiles
        parfor k = 1:size(label_neg_idx{idx},1)
            frame_num = label_neg_idx{idx}{k,1};
            fprintf('Process neg frame %d of date %s\n',frame_num,date{idx});
            tile_idx = label_neg_idx{idx}{k,2};
            tile = img2Tiles(data_mat.data(bbox_row,bbox_col,:,frame_num));
            tile_pre = img2Tiles(data_mat.data(bbox_row,bbox_col,:,frame_num-1));
            tile_pre2 = img2Tiles(data_mat.data(bbox_row,bbox_col,:,frame_num-2));
            tile_bg = img2Tiles(data_median_mat.median(bbox_row,bbox_col,:,frame_num));
            img_neg{k} = tile(tile_idx);
            img_neg_pre{k} = tile_pre(tile_idx);
            img_neg_pre2{k} = tile_pre2(tile_idx);
            img_neg_bg{k} = tile_bg(tile_idx);
        end
        % cat negtive images
        img_neg = cat(1,img_neg{:});
        img_neg = cat(4,img_neg{:});
        img_neg_pre = cat(1,img_neg_pre{:});
        img_neg_pre = cat(4,img_neg_pre{:});
        img_neg_pre2 = cat(1,img_neg_pre2{:});
        img_neg_pre2 = cat(4,img_neg_pre2{:});
        img_neg_bg = cat(1,img_neg_bg{:});
        img_neg_bg = cat(4,img_neg_bg{:});
        % save negative images
        label_neg{idx} = img_neg;
        label_neg_pre{idx} = img_neg_pre;
        label_neg_pre2{idx} = img_neg_pre2;
        label_neg_bg{idx} = img_neg_bg;
        fprintf('Done of date %s\n',date{idx});
    end

    data_train = struct();
    data_train.date = date';
    data_train.label_pos = label_pos;
    data_train.label_pos_bg = label_pos_bg;
    data_train.label_pos_pre = label_pos_pre;
    data_train.label_pos_pre2 = label_pos_pre2;
    data_train.label_neg = label_neg;
    data_train.label_neg_bg = label_neg_bg;
    data_train.label_neg_pre = label_neg_pre;
    data_train.label_neg_pre2 = label_neg_pre2;
    
    fprintf('Saving training data\n');
    save(fullfile(target_dir,'data_train.mat'),'data_train','-v7.3');
    
    % close workers
    delete(gcp('nocreate'));
    fprintf('Done\n');
end
toc