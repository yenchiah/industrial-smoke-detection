tic
clear all;
addpath(genpath('util'));

target_dir = 'frames';
load(fullfile(target_dir,'sun.mat'));

% set data source
date = {'2015-05-01','2015-05-02','2015-05-03','2015-05-04','2015-05-05','2015-05-06','2015-05-07','2015-05-08','2015-05-09','2015-01-26','2015-02-10','2015-03-06','2015-04-02','2015-05-28','2015-06-11','2015-07-08','2015-08-13','2015-09-09'};

for idx=1:numel(date)
    date_path = [date{idx},'.timemachine/'];
    dataset_path = 'crf26-12fps-1424x800/';
    tile_path = '1/2/2.mp4';
    path = fullfile(target_dir,date_path,dataset_path,tile_path);
    load(fullfile(path,'info.mat'));

    [sunrise_frame,sunset_frame] = getDayIdx(date{idx},sun(date{idx}).sunrise,sun(date{idx}).sunset,tm_json.capture_times);

    save(fullfile(path,'sun_frame.mat'),'sunrise_frame','sunset_frame','-v7.3');
end
toc