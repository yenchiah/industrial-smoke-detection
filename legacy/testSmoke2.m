clear all;
addpath(genpath('libs'));
addpath(genpath('util'));
select_box = 0;

% t = 5936;
t = 7543;
% t = 6617;
% t = 4406;
% t = 9011;
% t = 12929;
% t = [10312,10523];
% t = [4369,4406,5108,5936,6613,6617,7298,7435,7543,9011,12929,12566];
% t = [5936,6617,7438,7543,7577,9008,12494,12566,12929,6205];
% t = [4369,5108,5936,6613,6617,7298,7435,7543];
% t = [4406,4615,4860,4953,4995,5562,5969,6212,7327,7643,9014,9688,10078,10195,10312,10523,13100,13190,13418,13583,13871];

% t = [4371 4412 4448 4483 4531 4565 4606 4649 4680 4723 4773 4819 4872 ...
%      4916 4981 5032 5069 5108 5152 5192 5231 5279 5325 5368 5410 5449 ...
%      5493 5532 5590 5647 5683 5777 5865 5901 5936 5971 6004 6060 6099 ...
%      6246 6387 6497 6538 6614 7119 7298 7438 7542 9011 ...
%      10078 10312 10523 10840 11231 11619 12162 12281 12319 12399 12494 ...
%      12566 12637 12709 12747 12934 12985 13232 13383 13456 13830 13961];

% t = [4303 4309 4314 4320 4327 4338 4347 4359 4372 4417 4433 4448 4451 ...
%      4454 4463 4466 4469 4474 4477 4482 4488 4492 4502 4509 4525 4533 ...
%      4535 4540 4548 4556 4562 4568 4571 4588 4593 4598 4620 4629 4634 ...
%      4654 4658 4677 4686 4693 4698 4757 4763 4771 4821 4849 4858 4868 ...
%      4877 4880 4885 4889 4996 5021 5039 5079 5109 5130 5145 5151 5159 ...
%      5215 5224 5499 5505 5512 5521 5526 5530 5533 5576 5589 5594 5626 ...
%      5687 5722 5726 5928 5936 6232 6325 6346 6469 6616 6670 7299 7435 ...
%      7439 7445 7543 9658 11618 12072 12077 12083 12318 12322 12332 12548 ...
%      12566 12712 12718 12721 12730 12745 12753 12932 13078 13082 13093 ...
%      13220 13234 13382 13389 13406 13411 13418 13431 13448 13458 13577 ...
%      13579 13584 13587 13599 13608 13615 13622 13830 13835 13861 13867 ...
%      13954 13962];

% t = [5071 5133 5191 5260 5326 5395 5495 5574 5687 5783 5836 5938 6001 6089 ...
%      6166 6269 6365 6417 6475 6543 6604 6684 6749 6935 7005 7065 7204 7407 ...
%      8530 8827 9055 9805 9944 10549 10778 11009 13742 13869 13934];

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
    save(fullfile(path,'bbox.mat'),'bbox_row','bbox_col');
else
    load(fullfile(path,'bbox.mat'));
end

% compute filter bank (Laws' texture energy measures)
filter_bank = getFilterbank();

for i=1:numel(t)
    if(t(i)<3) 
        continue;
    end
    
    % crop an image and detect smoke
    img_label = label_mat.label(bbox_row,bbox_col,:,t(i));
    img = data_mat.data(bbox_row,bbox_col,:,t(i));
    img_bg = data_median_mat.median(bbox_row,bbox_col,:,t(i));
    tic
    [val,imgs_filtered] = detectSmoke2(img,img_bg,filter_bank);
    toc
    
    % visualize images
    fig = figure(50);
    img_cols = 9;
    img_rows = 3;
    fig_idx = 1;

    I = img;
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    I = imgs_filtered.img_lcn;
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    I = imgs_filtered.img_adj;
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    I = imgs_filtered.img_histeq;
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    I = label2rgb(imgs_filtered.tex_seg);
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = label2rgb(imgs_filtered.tex_seg_filtered);
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.img_gray_px;
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    I = label2rgb(imgs_filtered.tex_seg_rm_nongray);
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    I = label2rgb(imgs_filtered.tex_seg_rm_nongray_filtered);
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    I = imgs_filtered.img_black_px;
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    I = label2rgb(imgs_filtered.tex_seg_rm_nonblack);
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    I = label2rgb(imgs_filtered.tex_seg_rm_nonblack_filtered);
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    I = imgs_filtered.img_DoG;
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math); 
    
    I = imgs_filtered.img_entropy;
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.img_entropy_white_px;
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    I = imgs_filtered.img_entropy_black_px;
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.img_entropy_gray_px;
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    I = label2rgb(imgs_filtered.tex_seg_rm_highfreq);
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    I = imgs_filtered.tex_seg_clean;
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = img_bg;
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.img_bg_DoG;
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    I = imgs_filtered.img_bs_DoG;
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    I = imgs_filtered.img_bs;
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.img_bs_thr;
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    I = imgs_filtered.img_smoke;
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.img_smoke_clean;
    str = '';
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