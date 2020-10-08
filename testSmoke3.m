clear all;
addpath(genpath('libs'));
addpath(genpath('util'));
select_box = 0;

% 2015-05-02
% t = 10701;
% t = [5936,6617,7543];
% black smoke
% t = 5936;
t = 7543;
% t = 6613;
% gray smoke
% t = 7298;
% t = 7438;
% t = 6617;
% t = 7435;
% steam + smoke
% t = 5108;
% t = 4369;
% shadow + steam
% t = 6205;
% t = 4847;
% white smoke
% t = 12929;
% t = 12566;
% steam
% t = 5969;
% t = 4406;
% t = 4544;
% shadow
% t = [4847,4853,9776,9007];
% t = 4853;
% t = 9776;
% t = 9007;
% t = 9778;
% t = 9010;
% t = 9011;
% t = 10312;
% t = 10523;
% nothing
% t = 7000;
% t = 7111;
% t = 7577;

% 2015-05-02
% t = [9776,5936,7543,6613,7298,7438,6617,7435,5108,4369,6205,12929,12566,5969,4406,4544,4847,4853,9776,9007,7000,7111];

% 2015-05-01
% t = 13869;
% t = 13935;
% smoke + shadow
% t = 10770;
% t = [10772,10772,10772,10772];

% 2015-05-28
% t = 7171;

% collection
% 2015-05-02
% t = 4847;
% t = [5969,5969,5969];
% t = [6613,6613,6613];
% t = 6617;
% t = 9776;
% t = 12566;
% 2015-01-26
% t = 6446;
% 2015-05-28
% t = [7171,7171,7171,7171,7171];

% 2015-05-27
% t = [2035,2035,2035,2035,2035];

% set data source
date_path = '2015-05-02.timemachine/';
dataset_path = 'crf26-12fps-1424x800/';
tile_path = '1/2/2.mp4';

% read frames
target_dir = 'frames';
path = fullfile(target_dir,date_path,dataset_path,tile_path);
data_mat = matfile(fullfile(path,'data.mat'));
label_mat = matfile(fullfile(path,'label.mat'));
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
    
    % visualize images
    fig = figure(50);
    img_cols = 8;
    img_rows = 4;
    fig_idx = 1;

    I = img;
    str = 'img';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    I = imgs_filtered.imgs_HFCD.img_bg_DoG;
    str = 'img-bg-DoG';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    I = img_bg;
    str = 'img-bg';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    I = imgs_filtered.imgs_HFCD.img_DoG;
    str = 'img-DoG';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    I = imgs_filtered.imgs_HFCD.img_bs_DoG;
    str = 'img-bs-DoG';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    I = imgs_filtered.imgs_HFCD.img_bs_DoG_thr;
    str = 'img-bs-DoG-thr';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    I = imgs_filtered.imgs_HFCD.img_bs_DoG_thr_entropy;
    str = 'img-bs-DoG-thr-entropy';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    I = imgs_filtered.HFCD;
    str = 'HFCD';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    plot_flag_0 = sum(imgs_filtered.HFCD(:))>0;

    if(plot_flag_0)
        I = imgs_filtered.imgs_IICD.img_histeq;
    else
        I = ones(size(img))*0.5;
    end
    str = 'img-histeq';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    if(plot_flag_0)
        I = imgs_filtered.imgs_IICD.img_bg_histeq;
    else
        I = ones(size(img))*0.5;
    end
    str = 'img-bg-histeq';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    if(plot_flag_0)
        I = imgs_filtered.imgs_IICD.img_bs;
    else
        I = ones(size(img))*0.5;
    end
    str = 'img-bs';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    if(plot_flag_0)
        I = imgs_filtered.imgs_IICD.img_bs_thr;
    else
        I = ones(size(img))*0.5;
    end
    str = 'img-bs-thr';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    if(plot_flag_0)
        I = imgs_filtered.imgs_IICD.img_bs_thr_smooth;
    else
        I = ones(size(img))*0.5;
    end
    str = 'img-bs-thr-smooth';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    if(plot_flag_0)
        I = imgs_fd(:,:,:,1);
    else
        I = ones(size(img))*0.5;
    end
    str = 'img-last';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    if(plot_flag_0)
        I = imgs_filtered.imgs_IICD.img_last_histeq;
    else
        I = ones(size(img))*0.5;
    end
    str = 'img-last-histeq';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    if(plot_flag_0)
        I = imgs_filtered.imgs_IICD.img_last_diff;
    else
        I = ones(size(img))*0.5;
    end
    str = 'img-last-diff';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    if(plot_flag_0)
        I = imgs_filtered.imgs_IICD.img_last_diff_thr;
    else
        I = ones(size(img))*0.5;
    end
    str = 'img-last-diff-thr';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    if(plot_flag_0)
        I = imgs_filtered.imgs_IICD.img_last_diff_thr_smooth;
    else
        I = ones(size(img))*0.5;
    end
    str = 'img-last-diff-thr-smooth';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    if(plot_flag_0)
        I = imgs_filtered.IICD;
    else
        I = ones(size(img))*0.5;
    end
    str = 'IICD';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    if(plot_flag_0)
        I = imgs_filtered.HFCD_IICD;
    else
        I = ones(size(img))*0.5;
    end
    str = 'HFCD-IICD';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    if(plot_flag_0)
        img_masked = histeqRGB(imgs(:,:,:,2));
        img_masked(repmat(imgs_filtered.HFCD_IICD==0,1,1,3)) = 0;
        I = img_masked;
    else
        I = ones(size(img))*0.5;
    end
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    plot_flag_1 = sum(imgs_filtered.HFCD_IICD(:))>0;

    if(plot_flag_1)
        I = label2rgb(imgs_filtered.imgs_TS.tex_seg);
    else
        I = ones(size(img))*0.5;
    end
    str = 'tex-seg';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    if(plot_flag_1)
        I = label2rgb(imgs_filtered.TS);
    else
        I = ones(size(img))*0.5;
    end
    str = 'TS';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    if(plot_flag_1)
        I = label2rgb(imgs_filtered.imgs_BRF.tex_seg_shape);
    else
        I = ones(size(img))*0.5;
    end
    str = 'tex-seg-shape';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    if(plot_flag_1)
        I = imgs_filtered.imgs_BRF.img_adj;
    else
        I = ones(size(img))*0.5;
    end
    str = 'img-adj';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    if(plot_flag_1)
        I = label2rgb(imgs_filtered.imgs_BRF.tex_seg_group);
    else
        I = ones(size(img))*0.5;
    end
    str = 'tex-seg-group';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    if(plot_flag_1)
        I = label2rgb(imgs_filtered.imgs_BRF.tex_seg_gray);
    else
        I = ones(size(img))*0.5;
    end
    str = 'tex-seg-gray';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
   
    if(plot_flag_1)
        I = label2rgb(imgs_filtered.imgs_BRF.tex_seg_size);
    else
        I = ones(size(img))*0.5;
    end
    str = 'tex-seg-size';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    if(plot_flag_1)
        I = label2rgb(imgs_filtered.imgs_BRF.tex_seg_change);
    else
        I = ones(size(img))*0.5;
    end
    str = 'tex-seg-change';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    if(plot_flag_1)
        I = label2rgb(imgs_filtered.imgs_BRF.tex_seg_nonwhite);
    else
        I = ones(size(img))*0.5;
    end
    str = 'tex-seg-nonwhite';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    if(plot_flag_1)
        I = label2rgb(imgs_filtered.imgs_BRF.tex_seg_nonshadow);
    else
        I = ones(size(img))*0.5;
    end
    str = 'tex-seg-nonshadow';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    if(plot_flag_1)
        I = imgs_filtered.BRF;
    else
        I = ones(size(img))*0.5;
    end
    str = 'BRF';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    % print figure
    print_dir = 'figs';
    if ~exist(print_dir,'dir')
        mkdir(print_dir);
    end
    set(gcf,'PaperPositionMode','auto')
    print(fig,fullfile(print_dir,num2str(t(i))),'-dpng','-r0')
end