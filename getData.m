tic
clear all;
addpath(genpath('libs'));
addpath(genpath('util'));
generateComplexLabel = false;
generateSimpleLabel = true;
img_scale = 0.25;

date = getProcessingDates();
target_dir = 'frames';
load(fullfile(target_dir,'sun.mat'));

for idx=1:numel(date)
    try
        % set data source
        url_path = 'http://tiles.cmucreatelab.org/ecam/timemachines/shenango1/';
        date_path = [date{idx},'.timemachine/'];
        dataset_path = 'crf26-12fps-1424x800/';
        %tile_path = '1/2/2.mp4';
        %tile_path = '2/2/3.mp4';
        tile_path = '2/6/7.mp4';

        % download video and related information
        fprintf('Downloading video\n');
        tilename = [date{idx},'-tile.mp4'];
        urlwrite(strcat(url_path,date_path,dataset_path,tile_path),tilename);
        tm_json = JSON.parse(urlread(strcat(url_path,date_path,'tm.json')));
        r_json = JSON.parse(urlread(strcat(url_path,date_path,dataset_path,'r.json')));

        % read video and create directory
        tile = VideoReader(tilename);
        path = fullfile(target_dir,date_path,dataset_path,tile_path);
        if ~exist(path,'dir')
            mkdir(path);
        end

        % compute first frame
        fprintf('Processing frame 1 of %s\n',date{idx});
        img = imresize(readFrame(tile),img_scale);
        img_height = size(img,1);
        img_width = size(img,2);
        data = zeros(img_height,img_width,3,r_json.frames,'uint8');
        label = false(img_height,img_width,1,r_json.frames);
        has_label = false(1,r_json.frames);
        label_simple = false(1,r_json.frames);
        label_simple = uint8(label_simple);
        data(:,:,:,1) = img;
        %imwrite(img,fullfile(path,strcat(num2str(i),'.png')),'png');

        % separate video into frames
        for i=2:r_json.frames
            fprintf('Processing frame %d of %s\n',i,date{idx});
            data(:,:,:,i) = imresize(readFrame(tile),img_scale);
            %imwrite(img,fullfile(path,strcat(num2str(i),'.png')),'png');
        end

        % compute sunrise and sunset frames
        [sunrise_frame,sunset_frame] = getDayIdx(date{idx},sun(date{idx}).sunrise,sun(date{idx}).sunset,tm_json.capture_times);

        % delete video
        delete(tilename);

        % save files
        fprintf('Saving sun_frame.mat\n');
        save(fullfile(path,'sun_frame.mat'),'sunrise_frame','sunset_frame','-v7.3');
        fprintf('Saving data.mat\n');
        save(fullfile(path,'data.mat'),'data','-v7.3');
        fprintf('Saving file info.mat\n');
        save(fullfile(path,'info.mat'),'tm_json','r_json','url_path','dataset_path','tile_path','img_height','img_width');
        if(generateComplexLabel)
            fprintf('Saving label.mat\n');
            save(fullfile(path,'label.mat'),'label','-v7.3');
            fprintf('Saving has_label.mat\n');
            save(fullfile(path,'has_label.mat'),'has_label','-v7.3');
        end
        if(generateSimpleLabel)
            fprintf('Saving label_simple.mat\n');
            save(fullfile(path,'label_simple.mat'),'label_simple','-v7.3');
        end
        fprintf('Done\n');
    catch ME
        fprintf('Error getting data for date %s\n',date{idx});
        logError(ME);
        continue;
    end
end
toc