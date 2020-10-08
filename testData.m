clear all;
addpath(genpath('util'));
addpath(genpath('libs'));
addpath('/home/yenchiah/caffe/matlab');
this_dir = '/home/yenchiah/caffe/smoke-detection-caffe';

% create net
model = [this_dir,'/caffe/smoke_deploy.prototxt'];
weights = [this_dir,'/caffe/smoke_iter_24000.caffemodel'];
caffe.set_mode_gpu();
gpu_id = 0; 
caffe.set_device(gpu_id);
net = caffe.Net(model, weights, 'test');

% load data and label
path = [this_dir,'/frames/2015-05-01.timemachine/crf26-12fps-1424x800/1/2/2.mp4'];
data_mat = matfile(fullfile(path,'data.mat'));
label_mat = matfile(fullfile(path,'label.mat'));
load(fullfile(path,'has_label.mat'));

% print weights
C1 = net.layers('C1').params(1).get_data();
C1 = reshape(C1,size(C1,1),size(C1,2),[]);
C1 = permute(C1,[1 2 4 3]);
imdisp(mat2gray(C1),'Border',[0.05 0.05]);

% net forwarding
has_label_idx = find(has_label==1);
t = 30;
idx = has_label_idx(t);
img = normalizeData(data_mat.data(:,:,:,idx));
predict = net.forward({img});
map = predict{1};

% display images
figure
subplot(3,1,1)
imshow(permute(img,[2 1 3])+0.5)
subplot(3,1,2)
imshow(mat2gray(squeeze(label_mat.label(:,:,:,idx))))
subplot(3,1,3)
imshow(reshape(map,35,74))
