tic
clear all;
addpath(genpath('libs'));
addpath(genpath('util'));

date = getProcessingDates();
target_dir = 'frames';
window_size = [31,31,5];

for idx=1:numel(date)
    try
        % set data source
        date_path = [date{idx},'.timemachine/'];
        dataset_path = 'crf26-12fps-1424x800/';
        %tile_path = '2/2/3.mp4';
        tile_path = '2/6/7.mp4';
        
        % read optical flow and data
        path = fullfile(target_dir,date_path,dataset_path,tile_path);
        fprintf('Loading flow.mat of %s\n',date{idx});
        flow = load(fullfile(path,'flow.mat'));
        
        % compute variance
        fprintf('Computing turbulence of %s\n',date{idx});
        orientation = flow.flow.orientation;
        img = flow.flow.img;
        img_flow_var = stdfilt(orientation, ones(window_size));
        img_flow_var = img_flow_var.^2;
        
        % create video object
        v = VideoWriter(fullfile(path,'turbulence.mp4'),'MPEG-4');
        v.FrameRate = 10;
        open(v)
        
        % render
        margin = (window_size(3)-1)/2;
        fig = figure(1);
        for i=1+margin:size(img_flow_var,3)-margin
            fprintf('Processing frame %d of %s\n',i,date{idx});
            img_i = img(:,:,:,i);
            img_flow_var_i = mat2gray(img_flow_var(:,:,i));
            % visualization
            subplot(1,3,1)
            imshow(img_i,'Border','tight')
            subplot(1,3,2)
            imshow(img_flow_var_i,'Border','tight')
            subplot(1,3,3)
            imshow(img_i,'Border','tight')
            hold on
            h = imshow(img_flow_var_i,'Border','tight');
            colormap jet
            set(h, 'AlphaData', 0.3);
            hold off
            % write to video
            f_out = getframe(fig);
            writeVideo(v,f_out.cdata)
        end
        
        % close video
        close(v)
    catch ME
        fprintf('Error computing turbulence of date %s\n',date{idx});
        logError(ME);
        continue;
    end
end

toc