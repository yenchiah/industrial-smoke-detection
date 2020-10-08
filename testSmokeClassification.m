tic
clear all;
addpath(genpath('libs'));
addpath(genpath('util'));
warning('off','all')

% black smoke
t = 5936;
% t = 7543;
% t = 6613;
% gray smoke
% t = 7298;
% t = 7438;
% t = 6617;
% t = 7435;
% steam + smoke
% t = 5108;
% t = 4369;
% shadow + steam
% t = 6205;
% t = 4847;
% white smoke
% t = 12929;
% t = 12566;
% steam
% t = 5969;
% t = 4406;
% t = 4544;
% shadow
% t = 4847;
% t = 4853;
% t = 9776;
% t = 9007;
% t = 9778;
% t = 9010;
% t = 9011;
% t = 10312;
% t = 10523;
% nothing
% t = 7000;
% t = 7111;
% t = 7577;

date = getProcessingDates();

% load classifier
target_dir = 'frames';
fprintf('Loading classifier...\n');
load(fullfile(target_dir,'smoke_classifier.mat'));

% read mask
target_dir = 'frames';
fprintf('Loading bbox.mat\n');
load(fullfile(target_dir,'bbox.mat'));

% tile information
[~,num_tiles] = img2Tiles();

% feature information
[~,dimension] = computeFeature();

for idx=1:numel(t)
    current_frame = t(idx);
    
    % set data source
    date_path = '2015-05-02.timemachine/';
    dataset_path = 'crf26-12fps-1424x800/';
    tile_path = '1/2/2.mp4';
    
    % read frames
    path = fullfile(target_dir,date_path,dataset_path,tile_path);
    data_mat = matfile(fullfile(path,'data.mat'));
    data_median_mat = matfile(fullfile(path,'data_median_60.mat'));
    
    % get image data
    feature = ones(num_tiles,dimension);
    img = data_mat.data(bbox_row,bbox_col,:,current_frame);
    img_pre = data_mat.data(bbox_row,bbox_col,:,current_frame-1);
    img_pre2 = data_mat.data(bbox_row,bbox_col,:,current_frame-2);
    img_bg = data_median_mat.median(bbox_row,bbox_col,:,current_frame);
    
    % seperate image into tiles
    img = img2Tiles(img);
    img_pre = img2Tiles(img_pre);
    img_pre2 = img2Tiles(img_pre2);
    img_bg = img2Tiles(img_bg);
    
    % compute features
    for k=1:num_tiles
        f = computeFeature(img{k},img_bg{k},img_pre{k},img_pre2{k});
        f = normalizeFeature(f,feature_max,feature_min);
        feature(k,:) = f;
    end
    
    % classification
    label_test = ones(num_tiles,1);
    label_predict = svmpredict(label_test,feature,smoke_classifier);
    
    % visualization
    figure(999);
    img_cols = 4;
    img_rows = 4;
    fig_idx = 1;
    option = 'smallGraph2';
    
    order = [1,2,3,4;5,6,7,8;9,10,11,12;13,14,15,16];
    for k=1:numel(order)
        I = img{order(k)};
        str = num2str(label_predict(order(k))==1);
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);
    end
    
    figure(1000);
    img_cols = 3;
    img_rows = 3;
    fig_idx = 1;
    option = 'smallGraph2';
    
    order = [17,18,19;20,21,22;23,24,25];
    for k=1:numel(order)
        I = img{order(k)};
        str = num2str(label_predict(order(k))==1);
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);
    end
end