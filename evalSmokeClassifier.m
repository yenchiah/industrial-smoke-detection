tic
clear all;
addpath(genpath('libs'));
addpath(genpath('util'));
plot_result = true;
% plot_result = false;
smoke_level = 2;
target_dir = 'frames';

date = getProcessingDates();

for idx=1:numel(date)
    try
        fprintf('Processing date %s\n',date{idx});
        
        % set data source
        date_path = [date{idx},'.timemachine/'];
        dataset_path = 'crf26-12fps-1424x800/';
        tile_path = '1/2/2.mp4';
        path = fullfile(target_dir,date_path,dataset_path,tile_path);
        load(fullfile(path,'sun_frame.mat'));
        if(sunrise_frame < 100)
            sunrise_frame = 100;
        end
        
        % load the ground truth and the prediction
        load(fullfile(path,'label_simple.mat'));
        load(fullfile(path,'label_predict_classifier.mat'));
        
        % find local max
        min_peak_prominence = 1;
        min_peak_height = 1;
        min_peak_distance = 0;
        thr = 0;
        min_peak_width = 1;
        max_peak_width = 6;
        [pks,locs,w,p] = findpeaks(label_predict_classifier,'MinPeakProminence',min_peak_prominence,'MinPeakHeight',min_peak_height,'MinPeakDistance',min_peak_distance,'Threshold',thr,'MaxPeakWidth',max_peak_width,'MinPeakWidth',min_peak_width);

        % remove night time idx
        idx_remove = find(locs<sunrise_frame | locs>sunset_frame);
        pks(idx_remove) = [];
        locs(idx_remove) = [];
        w(idx_remove) = [];
        p(idx_remove) = [];

        % prediction
        predict = false(size(label_predict_classifier));
        for j=1:length(locs)
            w_ = w(j)*2;
            seg_start = round(locs(j)-w_);
            seg_end = round(locs(j)+w_);
            if(seg_start < 1)
                seg_start = 1;
            end
            if(seg_end > numel(predict))
                seg_end = numel(predict);
            end
            predict(seg_start:seg_end) = true;
        end
        predict = double(predict);
        
        if(plot_result)
            label_simple = double(label_simple);
            label_simple(1:sunrise_frame) = 0;
            label_simple(sunset_frame:end) = 0;
            label_simple_plot = label_simple;
            label_simple(label_simple<smoke_level) = 0;
            label_simple_plot = label_simple_plot-smoke_level+1;
            label_simple_plot(label_simple_plot>1) = 1;
            label_simple_plot(label_simple_plot<0) = 0;
            
            % compute F-score
            [fscore,predict_merged] = computeFscore(label_simple>=smoke_level,predict);
            fscore.date = date{idx}
            
            % plot ground truth and prediction
            fig = figure(105);
            fig_idx = 1;
            img_cols = 1;
            img_rows = 3;

            subplot(img_rows,img_cols,fig_idx)
            plot(label_predict_classifier,'b')
            xlim([sunrise_frame sunset_frame])
            title('Response of smoke detection')
            hold on
            plot(locs,pks,'ro')
            hold off
            fig_idx = fig_idx + 1;

            subplot(img_rows,img_cols,fig_idx)
            bar(predict_merged,'b')
            xlim([sunrise_frame sunset_frame])
            set(gca,'YTickLabel',[]);
            set(gca,'YTick',[]);
            round_to = 2;
            fscore_str = ['(',num2str(round(fscore.precision,round_to)),', ',num2str(round(fscore.recall,round_to)),', ',num2str(round(fscore.score,round_to)),')'];
            title(['Predicted frames: (precision, recall, fscore) = ',fscore_str])
            fig_idx = fig_idx + 1;

            subplot(img_rows,img_cols,fig_idx)
            bar(label_simple_plot,'r')
            xlim([sunrise_frame sunset_frame])
            set(gca,'YTickLabel',[]);
            set(gca,'YTick',[]);
            title(['Ground truth ( ',date{idx},' )'])
            fig_idx = fig_idx + 1;
            
            % print figure
            print_dir = 'figs';
            if ~exist(print_dir,'dir')
                mkdir(print_dir);
            end
            set(gcf,'PaperPositionMode','auto')
            print(fig,fullfile(print_dir,date{idx}),'-dpng','-r0')
        end   
    catch ME
        fprintf('Error detecting smoke of date %s\n',date{idx});
        logError(ME);
        continue;
    end
end

fprintf('Done\n');
toc