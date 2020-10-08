tic
clear all;
addpath(genpath('libs'));
addpath(genpath('util'));

date = getProcessingDates();
t_start = 7300;
t_end = 7500;

% read mask
target_dir = 'frames';
fprintf('Loading bbox_turbulence.mat\n');
load(fullfile(target_dir,'bbox_turbulence.mat'));

for idx=1:numel(date)
    try
        % set data source
        date_path = [date{idx},'.timemachine/'];
        dataset_path = 'crf26-12fps-1424x800/';
        %tile_path = '2/2/3.mp4';
        tile_path = '2/6/7.mp4';
        
        % read and crop frames
        path = fullfile(target_dir,date_path,dataset_path,tile_path);
        fprintf('Loading data.mat and cropping images of %s\n',date{idx});
        data_mat = matfile(fullfile(path,'data.mat'));
        data = data_mat.data(bbox_row,bbox_col,:,t_start-1:t_end);

        % allocate spaces
        num_imgs = t_end-t_start+1;
        flow.orientation = zeros(size(data,1),size(data,2),num_imgs);
        flow.img = zeros(size(data,1),size(data,2),size(data,3),num_imgs,'uint8');
        flow.start_frame = t_start;
        flow.end_frame = t_end;

        % compute optical flow
        for t=2:num_imgs+1
            fprintf('Processing frame %d of %s\n',t_start+(t-2),date{idx});
            img_pre = data(:,:,:,t-1);
            img = data(:,:,:,t);
            f = opticalFlow(im2double(rgb2gray(img)),im2double(rgb2gray(img_pre)));
            flow.img(:,:,:,t-1) = img;
            flow.orientation(:,:,t-1) = f.Orientation;
        end

        % save file
        fprintf('Saving flow.mat of %s\n',date{idx});
        save(fullfile(path,'flow.mat'),'flow','-v7.3');
    catch ME
        fprintf('Error computing optical flow of date %s\n',date{idx});
        logError(ME);
        continue;
    end
end

toc