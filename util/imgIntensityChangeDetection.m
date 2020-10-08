function [ IICD,imgs_IICD ] = imgIntensityChangeDetection( img,img_bg,imgs_fd )
    % background subtraction
    img_histeq = histeqRGB(img);
    img_bg_histeq = histeqRGB(img_bg);
    img_bs = backgroundSubtraction(img_histeq,img_bg_histeq,'Normalize');
    img_bs_thr = rgb2gray(img_bs);
    img_bs_thr = im2bw(img_bs_thr,0.08);
    img_bs_thr_smooth = morphology(img_bs_thr,2,'close');
    img_bs_thr_smooth = removeNoise(img_bs_thr_smooth);
    img_bs_thr_smooth = removeRegions(img_bs_thr_smooth,'smaller',150);
    
    % one frame differencing
    img_last_histeq = histeqRGB(imgs_fd(:,:,:,1));
    img_last_diff = backgroundSubtraction(img_histeq,img_last_histeq,'Normalize');
    img_last_diff_thr = rgb2gray(img_last_diff);
    img_last_diff_thr = im2bw(img_last_diff_thr,0.04);
    img_last_diff_thr_smooth = morphology(img_last_diff_thr,2,'close');
    img_last_diff_thr_smooth = removeNoise(img_last_diff_thr_smooth);
    img_last_diff_thr_smooth = removeRegions(img_last_diff_thr_smooth,'smaller',150);
    
    % combine results
    IICD = img_bs_thr_smooth & img_last_diff_thr_smooth;
    
    % return images
    imgs_IICD.img_histeq = img_histeq;
    imgs_IICD.img_bg_histeq = img_bg_histeq;
    imgs_IICD.img_bs = img_bs;
    imgs_IICD.img_bs_thr = img_bs_thr;
    imgs_IICD.img_bs_thr_smooth = img_bs_thr_smooth;
    imgs_IICD.img_last_histeq = img_last_histeq;
    imgs_IICD.img_last_diff = img_last_diff;
    imgs_IICD.img_last_diff_thr = img_last_diff_thr;
    imgs_IICD.img_last_diff_thr_smooth = img_last_diff_thr_smooth;
end

