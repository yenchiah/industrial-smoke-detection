clear all;
addpath(genpath('util'));

% load data and label
path_sep = '\'; % for windows
% path_sep = '/'; % for unix
data_files = searchFiles('frames',[path_sep,'data.mat']);
label_files = searchFiles('frames',[path_sep,'label.mat']);
has_label_files = searchFiles('frames',[path_sep,'has_label.mat']);

% network parameters
patch_size = 64;
patch_shift = 4;

for i=1:size(data_files,1)
    day_start_idx = 4300;
    day_end_idx = 14400;
    % read files
    data_mat = matfile(data_files{i});
    label_mat = matfile(label_files{i});
    load(has_label_files{i});
    % compute idx
    has_label_idx = find(has_label==1);
    no_label_idx = find(has_label==0);
    subsample_ratio = 12;
    no_label_idx = no_label_idx(day_start_idx:subsample_ratio:day_end_idx);
    % allocate data and label
    data_img = squeeze(data_mat.data(:,:,:,has_label_idx(1)));
    label_img = squeeze(label_mat.label(:,:,:,has_label_idx(1)));
    [patch_label_height,patch_label_width] = computePatchLabelSize(size(label_img),patch_size,patch_shift);
    num_patch = patch_label_height*patch_label_width;
    num_feature = 5;
    data_posi = zeros(num_feature,num_patch,numel(has_label_idx));
    data_nega = zeros(num_feature,num_patch,numel(no_label_idx));
    label_posi = zeros(num_patch,numel(has_label_idx));
    label_nega = zeros(num_patch,numel(no_label_idx));
    % construct positive data and label
    for j=1:numel(has_label_idx)
        fprintf('(Positive) Processing frame %d of dataset %d\n',j,i);
        idx_posi = has_label_idx(j);
        label_posi(:,j) = computePatchLabel(squeeze(label_mat.label(:,:,:,idx_posi)),patch_size,patch_shift);
        data_posi(:,:,j) = computePatchData(data_mat.data(:,:,:,idx_posi-2:idx_posi),patch_size,patch_shift);
    end
    % construct negative data and label
    for k=1:numel(no_label_idx)
        fprintf('(Negative) Processing frame %d of dataset %d\n',k,i);
        idx_nega = no_label_idx(k);
        label_nega(:,k) = computePatchLabel(squeeze(label_mat.label(:,:,:,idx_nega)),patch_size,patch_shift);
        data_nega(:,:,k) = computePatchData(data_mat.data(:,:,:,idx_nega-2:idx_nega),patch_size,patch_shift);
    end
    % save as HDF5
    target_dir = 'patch';
    if ~exist(target_dir,'dir')
        mkdir(target_dir);
    end
    patch_name_parts = strsplit(data_files{i},path_sep);
    patch_name_parts(1) = [];
    patch_name_parts(end) = [];
    patch_name = strjoin(patch_name_parts,'.');
    patch_name_posi = [target_dir,'/',patch_name,'.positive.h5'];
    patch_name_nega = [target_dir,'/',patch_name,'.negative.h5'];
    fprintf('Writing dataset %d\n',i);
    % display images
    figure
    subplot(3,1,1)
    imshow(squeeze(data_mat.data(:,:,:,idx_posi)))
    subplot(3,1,2)
    imshow(mat2gray(squeeze(label_mat.label(:,:,:,idx_posi))))
    subplot(3,1,3)
    imshow(reshape(label_posi(:,j),patch_label_height,patch_label_width))
end
fprintf('Done\n');