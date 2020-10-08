clear all;
addpath(genpath('libs'));
addpath(genpath('util'));
select_box = 1;

t = 4800:4820;

% set data source
target_dir = 'frames';
date_path = '2015-06-11.timemachine/';
dataset_path = 'crf26-12fps-1424x800/';
%tile_path = '2/2/3.mp4';
tile_path = '2/6/7.mp4';

% read frames
path = fullfile(target_dir,date_path,dataset_path,tile_path);
data_mat = matfile(fullfile(path,'data.mat'));

% define mask
if(select_box == 1)
    t_ref = 11000;
    img = data_mat.data(:,:,:,t_ref);
    [bbox_row,bbox_col] = selectBound(img);
    save(fullfile(target_dir,'bbox_turbulence.mat'),'bbox_row','bbox_col');
else
    load(fullfile(target_dir,'bbox_turbulence.mat'));
end

% create video object
% v = VideoWriter('turbulence.mp4','MPEG-4');
% v.FrameRate = 10;
% open(v)

% create optical flow object
opticFlow = vision.OpticalFlow('Method','Lucas-Kanade','ReferenceFrameSource','Input port');

% loop frames
fig = figure(1);
for i=1:numel(t)
    % read frames
    img_pre = data_mat.data(bbox_row,bbox_col,:,t(i)-1);
    img = data_mat.data(bbox_row,bbox_col,:,t(i));
    
    % compute optical flow and variance of directions
    flow = opticalFlow(im2double(rgb2gray(img)),im2double(rgb2gray(img_pre)));
    img_flow_var = stdfilt(flow.Orientation, ones(23));
    img_flow_var = img_flow_var.^2;
    img_flow_var = mat2gray(img_flow_var);
    
    % write to video
    t(i)
    
    % visualization
    subplot(1,3,1)
    imshow(img,'Border','tight')
    subplot(1,3,2)
    imshow(img_flow_var,'Border','tight')
    subplot(1,3,3)
    imshow(img,'Border','tight')
    hold on
    h = imshow(img_flow_var,'Border','tight');
    colormap jet
    set(h, 'AlphaData', 0.3);
    hold off
    pause(0.05)
    
    % write to video
%     f_out = getframe(fig);
%     writeVideo(v,f_out.cdata)
end

% close(v)