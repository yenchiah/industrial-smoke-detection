function [ HFCD,imgs_HFCD ] = highFreqChangeDetection( img,img_bg )
    % detect high frequency changes in the image
    img_DoG = mat2gray(diffOfGaussian(img,0.5,3));
    img_bg_DoG = mat2gray(diffOfGaussian(img_bg,0.5,3));
    img_bs_DoG = mat2gray(backgroundSubtraction(img_DoG,img_bg_DoG,'Normalize'));
    r_thr = 0.1;
    g_thr = 0.1;
    b_thr = 0.1;
    img_bs_DoG_thr = img_bs_DoG(:,:,1)>r_thr & img_bs_DoG(:,:,2)>g_thr & img_bs_DoG(:,:,3)>b_thr;
    img_bs_DoG_thr_entropy = entropyfilt(img_bs_DoG_thr,true(9,9));
    img_bs_DoG_thr_entropy = im2bw(img_bs_DoG_thr_entropy,0.65);
    img_bs_DoG_thr_entropy = morphology(img_bs_DoG_thr_entropy,2,'close');
    img_bs_DoG_thr_entropy_clean = removeRegions(img_bs_DoG_thr_entropy,'smaller',100);
    img_bs_DoG_thr_entropy_clean = mat2gray(img_bs_DoG_thr_entropy_clean);
    
    % return images
    imgs_HFCD.img_DoG = img_DoG;
    imgs_HFCD.img_bg_DoG = img_bg_DoG;
    imgs_HFCD.img_bs_DoG = img_bs_DoG;
    imgs_HFCD.img_bs_DoG_thr = img_bs_DoG_thr;
    imgs_HFCD.img_bs_DoG_thr_entropy = img_bs_DoG_thr_entropy;
    HFCD = img_bs_DoG_thr_entropy_clean;
end

