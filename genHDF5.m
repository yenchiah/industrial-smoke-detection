clear all;
addpath(genpath('util'));

% load data and label
% path_sep = '\'; % for windows
path_sep = '/'; % for unix
data_files = searchFiles('frames',[path_sep,'data.mat']);
label_files = searchFiles('frames',[path_sep,'label.mat']);
has_label_files = searchFiles('frames',[path_sep,'has_label.mat']);

% network parameters
num_pooling_layer = 2;
patch_size = 64;
patch_shift = 2^num_pooling_layer;

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
    subsample_ratio = 16;
    no_label_idx = no_label_idx(day_start_idx:subsample_ratio:day_end_idx);
    % allocate data and label for caffe training
    data_img = squeeze(data_mat.data(:,:,:,has_label_idx(1)));
    label_img = squeeze(label_mat.label(:,:,:,has_label_idx(1)));
    [patch_label_height,patch_label_width] = computePatchLabelSize(size(label_img),patch_size,patch_shift);
    data_caffe_posi = zeros(size(data_img,2),size(data_img,1),size(data_img,3),numel(has_label_idx));
    data_caffe_nega = zeros(size(data_img,2),size(data_img,1),size(data_img,3),numel(no_label_idx));
    label_caffe_posi = zeros(patch_label_width*patch_label_height,numel(has_label_idx));
    label_caffe_nega = zeros(patch_label_width*patch_label_height,numel(no_label_idx));
    % construct positive data and label
    for j=1:numel(has_label_idx)
        fprintf('(Positive) Processing frame %d of dataset %d\n',j,i);
        label_caffe_posi(:,j) = computePatchLabel(squeeze(label_mat.label(:,:,:,has_label_idx(j))),patch_size,patch_shift);
        data_caffe_posi(:,:,:,j) = normalizeData(data_mat.data(:,:,:,has_label_idx(j)));
    end
    % construct negative data and label
    for k=1:numel(no_label_idx)
        fprintf('(Negative) Processing frame %d of dataset %d\n',k,i);
        label_caffe_nega(:,k) = computePatchLabel(squeeze(label_mat.label(:,:,:,no_label_idx(k))),patch_size,patch_shift);
        data_caffe_nega(:,:,:,k) = normalizeData(data_mat.data(:,:,:,no_label_idx(k)));
    end
    % save as HDF5
    target_dir = 'caffe';
    if ~exist(target_dir,'dir')
        mkdir(target_dir);
    end
    h5name_parts = strsplit(data_files{i},path_sep);
    h5name_parts(1) = [];
    h5name_parts(end) = [];
    h5name = strjoin(h5name_parts,'.');
    h5name_posi = [target_dir,'/',h5name,'.positive.h5'];
    h5name_nega = [target_dir,'/',h5name,'.negative.h5'];
    data_caffe_posi = single(data_caffe_posi);
    label_caffe_posi = single(label_caffe_posi);
    data_caffe_nega = single(data_caffe_nega);
    label_caffe_nega = single(label_caffe_nega);
    fprintf('Writing dataset %d\n',i);
    h5create(h5name_posi, '/data', size(data_caffe_posi), 'Datatype', 'single');
    h5create(h5name_posi, '/label', size(label_caffe_posi), 'Datatype', 'single');
    h5create(h5name_nega, '/data', size(data_caffe_nega), 'Datatype', 'single');
    h5create(h5name_nega, '/label', size(label_caffe_nega), 'Datatype', 'single');
    h5write(h5name_posi, '/data', data_caffe_posi);
    h5write(h5name_posi, '/label', label_caffe_posi);
    h5write(h5name_nega, '/data', data_caffe_nega);
    h5write(h5name_nega, '/label', label_caffe_nega);
    % display images
    figure
    subplot(1,3,1)
    imshow(permute(squeeze(data_caffe_posi(:,:,:,j)),[2 1 3])+0.5)
    subplot(1,3,2)
    imshow(mat2gray(squeeze(label_mat.label(:,:,:,has_label_idx(j)))))
    subplot(1,3,3)
    imshow(reshape(label_caffe_posi(:,j),patch_label_height,patch_label_width))
end
fprintf('Done\n');
