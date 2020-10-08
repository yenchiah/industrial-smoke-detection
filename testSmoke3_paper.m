clear all;
addpath(genpath('libs'));
addpath(genpath('util'));
select_box = 0;
plot_HFCD = false;
plot_IICD = false;
plot_TEX = false;
plot_SEG = false;
plot_BRF = false;
plot_SUMMARY = true;

t = 7543;

% 2015-05-01
% t = [10772,10772,10772,10772];

% 2015-05-27
% t = [2035,2035,2035,2035,2035];

% true positive
% 2015-05-02
% t = 4847;
% t = 5936;
% t = 6617;
% t = 9776;

% true negative
% 2015-05-02
% t = 7000;

% false positive
% 2015-05-02
% t = [5969,5969,5969];
% 2015-05-28
% t = [7171,7171,7171,7171,7171];
% 2015-09-09
% t = 11940;

% false negative
% 2015-05-02
% t = 12566;
% t = [6613,6613,6613];
% 2015-01-26
% t = 6446;

% set data source
date_path = '2015-05-02.timemachine/';
dataset_path = 'crf26-12fps-1424x800/';
tile_path = '1/2/2.mp4';

% read frames
target_dir = 'frames';
path = fullfile(target_dir,date_path,dataset_path,tile_path);
data_mat = matfile(fullfile(path,'data.mat'));
% label_mat = matfile(fullfile(path,'label.mat'));
data_median_mat = matfile(fullfile(path,'data_median_60.mat'));

% define mask
if(select_box == 1)
    t_ref = 5936;
    img = data_mat.data(:,:,:,t_ref);
    [bbox_row,bbox_col] = selectBound(img);
    save(fullfile(target_dir,'bbox.mat'),'bbox_row','bbox_col');
else
    load(fullfile(target_dir,'bbox.mat'));
end

% compute filter bank (Laws' texture energy measures)
filter_bank = getFilterbank();

for i=1:numel(t)
    if(t(i)<3) 
        continue;
    end
    
    % crop an image and detect smoke
%     img_label = label_mat.label(bbox_row,bbox_col,:,t(i));
    span = getTemporalSpan();
    imgs = data_mat.data(bbox_row,bbox_col,:,t(i)-span:span:t(i));
    imgs_fd = imgs(:,:,:,1);
    img_bg = data_median_mat.median(bbox_row,bbox_col,:,t(i));
    img = imgs(:,:,:,2);
    tic
    [val,imgs_filtered] = detectSmoke3(img,img_bg,filter_bank,imgs_fd);
    toc
    
    option = 'largeFont';
    
    if(plot_HFCD)
        % visualize images
        fig = figure(51);
        img_cols = 4;
        img_rows = 2;
        fig_idx = 1;

        I = img;
        str = '$I_{t}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = img_bg;
        str = '$B_{t}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = imgs_filtered.imgs_HFCD.img_DoG;
        str = '$I_{dog}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = imgs_filtered.imgs_HFCD.img_bg_DoG;
        str = '$B_{dog}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = imgs_filtered.imgs_HFCD.img_bs_DoG;
        str = '$S_{dog}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = imgs_filtered.imgs_HFCD.img_bs_DoG_thr;
        str = '$S_{dog}>T_{1}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = imgs_filtered.imgs_HFCD.img_bs_DoG_thr_entropy;
        str = '$E_{dog}>T_{2}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = imgs_filtered.HFCD;
        str = '$M_{dog}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        % print figure
        print_dir = 'figs';
        if ~exist(print_dir,'dir')
            mkdir(print_dir);
        end
        set(gcf,'PaperPositionMode','auto')
        print(fig,fullfile(print_dir,[num2str(t(i)),'_1']),'-dpng','-r0')
    end
    
    if(plot_IICD)
        % visualize images
        fig = figure(52);
        img_cols = 4;
        img_rows = 2;
        fig_idx = 1;

        I = imgs_filtered.imgs_IICD.img_histeq;
        str = '$I_{heq} = \mathrm{CLAHE}(I_t)$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = imgs_filtered.imgs_IICD.img_bg_histeq;
        str = '$B_{heq} = \mathrm{CLAHE}(B_t)$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = imgs_filtered.imgs_IICD.img_bs_thr;
        str = '$S_{heq}>T_{3}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = imgs_filtered.imgs_IICD.img_bs_thr_smooth;
        str = '$M_{heq1}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = imgs_filtered.imgs_IICD.img_last_histeq;
        str = '$I''_{heq} = \mathrm{CLAHE}(I_{t-2})$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = imgs_filtered.imgs_IICD.img_last_diff_thr;
        str = '$F_{heq}>T_{4}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = imgs_filtered.imgs_IICD.img_last_diff_thr_smooth;
        str = '$M_{heq2}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = imgs_filtered.IICD;
        str = '$M_{heq} = M_{heq1} \;\&\; M_{heq2}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        % print figure
        print_dir = 'figs';
        if ~exist(print_dir,'dir')
            mkdir(print_dir);
        end
        set(gcf,'PaperPositionMode','auto')
        print(fig,fullfile(print_dir,[num2str(t(i)),'_2']),'-dpng','-r0')
    end
    
    if(plot_TEX)
        % visualize images
        fig = figure(53);
        img_cols = 4;
        img_rows = 2;
        fig_idx = 1;
             
        I = label2rgb(imgs_filtered.imgs_TS.tex_seg);
        str = '$R_{t}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = label2rgb(imgs_filtered.TS);
        str = '$R_{smooth}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = imgs_filtered.imgs_BRF.img_adj;
        str = '$I_{adj}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);
        
        I = mat2gray(imgs_filtered.imgs_BRF.img_bs);
        str = '$S_{t}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);
        
        I = imgs_filtered.HFCD_IICD;
        str = '$M_{cd} = M_{dog} \;\&\; M_{heq}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);
          
        I = label2rgb(imgs_filtered.imgs_BRF.tex_seg_nonshadow);
        str = '$R_{filter}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option); 

        I = imgs_filtered.BRF;
        str = '$M_{t}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);
        
        img_masked = imgs_filtered.imgs_BRF.img_adj;
        img_masked(repmat(imgs_filtered.BRF==0,1,1,3)) = 0;
        I = img_masked;
        str = '$I_{adj}(M_{t})$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);
        
        % print figure
        print_dir = 'figs';
        if ~exist(print_dir,'dir')
            mkdir(print_dir);
        end
        set(gcf,'PaperPositionMode','auto')
        print(fig,fullfile(print_dir,[num2str(t(i)),'_3']),'-dpng','-r0')  
    end
    
    if(plot_SEG)
        % visualize images
        fig = figure(54);
        img_cols = 4;
        img_rows = 2;
        fig_idx = 1;
        
        I = img;
        str = '$I_{t}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);
        
        I = imgs_filtered.imgs_IICD.img_histeq;
        str = '$I_{heq}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);
        
        I = label2rgb(imgs_filtered.imgs_TS.tex_seg);
        str = '$R_{t}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = label2rgb(imgs_filtered.TS);
        str = '$R_{smooth}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        % print figure
        print_dir = 'figs';
        if ~exist(print_dir,'dir')
            mkdir(print_dir);
        end
        set(gcf,'PaperPositionMode','auto')
        print(fig,fullfile(print_dir,[num2str(t(i)),'_4']),'-dpng','-r0')  
    end
  
    if(plot_BRF)
        % visualize images
        fig = figure(55);
        img_cols = 6;
        img_rows = 2;
        fig_idx = 1;

        I = label2rgb(imgs_filtered.TS);
        str = '$R_{smooth}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);
        
        I = label2rgb(imgs_filtered.imgs_BRF.tex_seg_shape);
        str = 'shape';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);
         
        I = imgs_filtered.imgs_BRF.img_adj;
        str = '$I_{adj}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);
        
        I = label2rgb(imgs_filtered.imgs_BRF.tex_seg_group);
        str = 'group';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);
        
        I = label2rgb(imgs_filtered.imgs_BRF.tex_seg_gray);
        str = 'grayish';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);
        
        I = label2rgb(imgs_filtered.imgs_BRF.tex_seg_size);
        str = 'size';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);
        
        I = imgs_filtered.HFCD_IICD;
        str = '$M_{cd} = M_{dog} \;\&\; M_{heq}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);
        
        I = label2rgb(imgs_filtered.imgs_BRF.tex_seg_change);
        str = 'change';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = label2rgb(imgs_filtered.imgs_BRF.tex_seg_nonwhite);
        str = 'nonwhite';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);
        
        I = mat2gray(imgs_filtered.imgs_BRF.img_bs);
        str = '$S_{t}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = label2rgb(imgs_filtered.imgs_BRF.tex_seg_nonshadow);
        str = 'nonshadow';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);        

        I = imgs_filtered.BRF;
        str = '$M_{t}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);
        
        % print figure
        print_dir = 'figs';
        if ~exist(print_dir,'dir')
            mkdir(print_dir);
        end
        set(gcf,'PaperPositionMode','auto')
        print(fig,fullfile(print_dir,[num2str(t(i)),'_5']),'-dpng','-r0')  
    end
    
    if(plot_SUMMARY)
        % visualize images
        fig = figure(56);
        img_cols = 4;
        img_rows = 2;
        fig_idx = 1;
        
        I = img;
        str = '$I_{t}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);
        
        I = img_bg;
        str = '$B_{t}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = imgs_filtered.imgs_HFCD.img_DoG;
        str = '$I_{d}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = imgs_filtered.imgs_HFCD.img_bg_DoG;
        str = '$B_{d}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);
        
        I = imgs_filtered.imgs_HFCD.img_bs_DoG_thr;
        str = '$S_{d}=\mathrm{imSub}(I_{d},B_{d})$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = imgs_filtered.HFCD;
        str = '$M_{d}=\mathrm{ent}(S_{d})>T$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);
        
        I = imgs_filtered.imgs_IICD.img_histeq;
        str = '$I_{h}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = imgs_filtered.imgs_IICD.img_bg_histeq;
        str = '$B_{h}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);
        
        % print figure
        print_dir = 'figs';
        if ~exist(print_dir,'dir')
            mkdir(print_dir);
        end
        set(gcf,'PaperPositionMode','auto')
        print(fig,fullfile(print_dir,[num2str(t(i)),'_5_1']),'-dpng','-r0')
        
        % visualize images
        fig = figure(57);
        img_cols = 4;
        img_rows = 2;
        fig_idx = 1;
        
        I = imgs_filtered.imgs_IICD.img_bs_thr_smooth;
        str = '$M_{h}=\mathrm{imSub}(I_{h},B_{h})$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);
        
        I = imgs_filtered.imgs_IICD.img_last_histeq;
        str = '$I''_{h}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = imgs_filtered.imgs_IICD.img_last_diff_thr_smooth;
        str = '$M''_{h}=\mathrm{imSub}(I_{h},I''_{h})$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = imgs_filtered.HFCD_IICD;
        str = '$M_{t} = M_{d} \& M_{h} \& M''_{h}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = label2rgb(imgs_filtered.imgs_TS.tex_seg);
        str = '$R_{seg}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);
        
        I = label2rgb(imgs_filtered.imgs_BRF.tex_seg_nonshadow);
        str = '$R_{filt}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option); 

        I = imgs_filtered.BRF;
        str = '$R_{t}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);
        
        img_masked = img;
        img_masked(repmat(imgs_filtered.BRF==0,1,1,3)) = 0;
        I = img_masked;
        str = '$I_{t}(R_{t})$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);
        
        % print figure
        print_dir = 'figs';
        if ~exist(print_dir,'dir')
            mkdir(print_dir);
        end
        set(gcf,'PaperPositionMode','auto')
        print(fig,fullfile(print_dir,[num2str(t(i)),'_5_2']),'-dpng','-r0') 
    end
end