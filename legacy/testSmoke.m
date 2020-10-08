clear all;
addpath(genpath('libs'));
addpath(genpath('util'));
select_box = 0;

% t = 5936;
% t = 7543;
% t = 6617;
t = 7000;
% t = 4406;
% t = 9011;
% t = 12929;
% t = [10312,10523];
% t = [5936,6617,7438,7543,7577,9008,12494,12566,12929,6205];
% t = [4369,5108,5936,6613,6617,7298,7435,7543];
% t = [4406,4615,4860,4953,4995,5562,5969,6212,7327,7643,9014,9688,10078,10195,10312,10523,13100,13190,13418,13583,13871];

% t = [4371 4412 4448 4483 4531 4565 4606 4649 4680 4723 4773 4819 4872 ...
%      4916 4981 5032 5069 5108 5152 5192 5231 5279 5325 5368 5410 5449 ...
%      5493 5532 5590 5647 5683 5777 5865 5901 5936 5971 6004 6060 6099 ...
%      6246 6387 6497 6538 6614 7119 7298 7438 7542 9011 ...
%      10078 10312 10523 10840 11231 11619 12162 12281 12319 12399 12494 ...
%      12566 12637 12709 12747 12934 12985 13232 13383 13456 13830 13961];

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
texture_mat = matfile(fullfile(path,'texture.mat'));
texture_median_mat = matfile(fullfile(path,'texture_median.mat'));

% define mask
if(select_box == 1)
    t_ref = 5936;
    img = data_mat.data(:,:,:,t_ref);
    [bbox_row,bbox_col] = selectBound(img);
    save(fullfile(path,'bbox.mat'),'bbox_row','bbox_col');
else
    load(fullfile(path,'bbox.mat'));
end

for i=1:numel(t)
    if(t(i)<3)
        continue;
    end
    
    % crop an image and detect smoke
    img_label = label_mat.label(bbox_row,bbox_col,:,t(i));
    img = data_mat.data(bbox_row,bbox_col,:,t(i));
    img_bg = data_median_mat.median(bbox_row,bbox_col,:,t(i));
    tex = texture_mat.texture(bbox_row,bbox_col,:,t(i));
    tex_bg = texture_median_mat.texture_median(bbox_row,bbox_col,:);
    tic
    imgs_filtered = detectSmoke(img,img_bg,tex,tex_bg);
    toc
    
    % visualize images
    fig = figure(50);
    img_cols = 9;
    img_rows = 4;
    fig_idx = 1;

    I = img;
    str = 'Current image $I_t$';
    math = ['t = ',num2str(t(i))];
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = img_bg;
    str = 'Background $B_t$';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.img_smooth_lcn;
    str = '$$I_{lcn} = \mathrm{LCN}(I_t)$$';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.img_bg_smooth_lcn;
    str = '$$B_{lcn} = \mathrm{LCN}(B_t)$$';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);    

    I = imgs_filtered.img_bs;
    str = '$$D_{lcn} = \mathrm{bgSub}(I_{lcn},B_{lcn})$$';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = rgb2gray(imgs_filtered.img_bs_thr)>0;
    str = 'Threshold $D_{lcn}$';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.img_black_px;
    str = 'Black $I_{lcn}$ px';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.img_bs_rmblack;
    str = 'Remove non-black $I_{lcn}$';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.img_gray_px;
    str = 'Grayish $I_{lcn}$ px';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.img_bs_rmcolor;
    str = 'Remove non-grayish $I_{lcn}$';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.img_lowS_px;
    str = 'Low S px in $I_{lcn}$';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.img_bs_rmlowS;
    str = 'Remove high S in $I_{lcn}$';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.img_DoG;
    str = '$$I_{dg} = \mathrm{DoG}(I_t)$$';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.img_bg_DoG;
    str = '$$B_{dg} = \mathrm{DoG}(B_t)$$';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.img_DoGdiff;
    str = '$$D_{dg} = \mathrm{bgSub}(I_{dg},B_{dg})$$';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.img_DoGdiff_thr;
    str = 'Threshold $D_{dg}$';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.img_DoGdiff_entropy_px;
    str = '$$E_{dg} = \mathrm{Entropy}(D_{dg})$$';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.img_bs_rmLowDoGdiff;
    str = 'Remove low $E_{dg}$';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = tex;
    str = 'Current texture $T_t$';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math); 

    I = tex_bg;
    str = 'Background texture $P_t$';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math); 
    
    I = imgs_filtered.tex_smooth;
    str = '$$T_{bi} = \mathrm{bltSmooth}(T_t)$$';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math); 
    
    I = imgs_filtered.tex_bg_smooth;
    str = '$$P_{bi} = \mathrm{bltSmooth}(P_t)$$';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);     
    
    I = imgs_filtered.tex_bs;
    str = '$$S_{bi} = \mathrm{bgSub}(T_{bi},P_{bi})$$';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);    
    
    I = imgs_filtered.tex_gray_px;
    str = 'Grayish $T_{bi}$ px';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    I = imgs_filtered.img_bs_rmColorTex;
    str = 'Remove non-grayish $T_{bi}$';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = mat2gray(imgs_filtered.tex_DoG);
    str = '$$T_{dg} = \mathrm{DoG}(T_{bi})$$';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = mat2gray(imgs_filtered.tex_bg_DoG);
    str = '$$P_{dg} = \mathrm{DoG}(P_{bi})$$';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.tex_DoGdiff;
    str = '$$S_{dg} = \mathrm{bgSub}(T_{dg},P_{dg})$$';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    I = imgs_filtered.tex_DoGdiff_thr;
    str = 'Threshold $S_{dg}$';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.tex_DoGdiff_entropy_px;
    str = '$$N_{dg} = \mathrm{Entropy}(S_{dg})$$';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.img_bs_rmLowDoGTexdiff;
    str = 'Remove low $N_{dg}$';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.img_bs_mask;
    str = 'Create a mask';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.img_bs_mask_smooth;
    str = 'Smooth the mask';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.img_bs_mask_clean;
    str = 'Remove noise';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = img_label;
    str = 'Ground truth';
    math = '$$T_t$$';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    % print figure
    print_dir = 'figs';
    if ~exist(print_dir,'dir')
        mkdir(print_dir);
    end
    set(gcf,'PaperPositionMode','auto')
    print(fig,fullfile(print_dir,num2str(t(i))),'-dpng','-r0')
end