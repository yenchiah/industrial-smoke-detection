function imgs_filtered = detectSmoke( img,img_bg,tex,tex_bg )
    % image smoothing
    img_smooth = gaussianSmooth(img,0.5);
    img_bg_smooth = gaussianSmooth(img_bg,0.5);

    % local contrast normalization
    img_smooth_lcn = mat2gray(localnormalize(double(img_smooth),64,64));
    img_bg_smooth_lcn = mat2gray(localnormalize(double(img_bg_smooth),64,64));
     
    imgs_filtered.img_smooth_lcn = img_smooth_lcn;   
    imgs_filtered.img_bg_smooth_lcn = img_bg_smooth_lcn; 
    
    % background subtraction of images
    img_bs = backgroundSubtraction(img_smooth_lcn,img_bg_smooth_lcn,'Normalize');
    img_bs = mat2gray(localnormalize(double(img_bs),64,64));
    
    imgs_filtered.img_bs = img_bs;

    % threshold the background subtraction of images
    thr = 0.07;
	img_bs_thr = img_bs;
    img_bs_thr(repmat(rgb2gray(img_bs_thr)<thr,1,1,3)) = 0;
    
    imgs_filtered.img_bs_thr = img_bs_thr;

    % remove pixels that are not black
    r = img_smooth_lcn(:,:,1);
    g = img_smooth_lcn(:,:,2);
    b = img_smooth_lcn(:,:,3);
    r_thr = 0.4;
    g_thr = 0.4;
    b_thr = 0.6;
    img_black_px = r<r_thr & g<g_thr & b<b_thr;
    img_bs_rmblack = img_bs_thr;
    img_bs_rmblack(~repmat(img_black_px,1,1,3)) = 0;

    imgs_filtered.img_bs_rmblack = img_bs_rmblack;
    imgs_filtered.img_black_px = img_black_px;

    % remove pixels that are not gray
    rg_thr = 0.07;
    gb_thr = 0.07;
    rb_thr = 0.15;
    img_gray_px = abs(r-g)<rg_thr & abs(r-b)<rb_thr & abs(g-b)<gb_thr;
    img_bs_rmcolor = img_bs_rmblack;
    img_bs_rmcolor(~repmat(img_gray_px,1,1,3)) = 0;

    imgs_filtered.img_bs_rmcolor = img_bs_rmcolor;
    imgs_filtered.img_gray_px = img_gray_px;
 
    % remove pixels that have high saturation
    img_hsv = rgb2hsv(img_smooth_lcn);
    img_lowS_px = img_hsv(:,:,2)<0.55;
    img_bs_rmlowS = img_bs_rmcolor;
    img_bs_rmlowS(~repmat(img_lowS_px,1,1,3)) = 0;

    imgs_filtered.img_bs_rmlowS = img_bs_rmlowS;
    imgs_filtered.img_lowS_px = img_lowS_px;

    % remove pixels that have low background subtraction of DoG
    img_DoG = mat2gray(diffOfGaussian(img_smooth,0.5,3));
    img_bg_DoG = mat2gray(diffOfGaussian(img_bg_smooth,0.5,3));
    img_DoGdiff = mat2gray(backgroundSubtraction(img_DoG,img_bg_DoG,'Normalize'));
    r_thr = 0.1;
    g_thr = 0.1;
    b_thr = 0.1;
    img_DoGdiff_thr = img_DoGdiff(:,:,1)>r_thr & img_DoGdiff(:,:,2)>g_thr & img_DoGdiff(:,:,3)>b_thr;
    img_DoGdiff_entropy_px = entropyfilt(img_DoGdiff_thr,true(9,9));
    img_DoGdiff_entropy_px = im2bw(img_DoGdiff_entropy_px,0.75);
    img_bs_rmLowDoGdiff = img_bs_rmlowS;
    img_bs_rmLowDoGdiff(~repmat(img_DoGdiff_entropy_px,1,1,3)) = 0;

    imgs_filtered.img_DoG = img_DoG;
    imgs_filtered.img_bg_DoG = img_bg_DoG;
    imgs_filtered.img_DoGdiff = img_DoGdiff;
    imgs_filtered.img_DoGdiff_thr = img_DoGdiff_thr;
    imgs_filtered.img_DoGdiff_entropy_px = img_DoGdiff_entropy_px;
    imgs_filtered.img_bs_rmLowDoGdiff = img_bs_rmLowDoGdiff;

    % background subtraction of textures
    tex_smooth = bilateralSmooth(tex,0.2,10);
    tex_bg_smooth = bilateralSmooth(tex_bg,0.2,10);
    tex_bs = backgroundSubtraction(tex_smooth,tex_bg_smooth,'Normalize');
    tex_bs = mat2gray(localnormalize(double(tex_bs),64,64));

    imgs_filtered.tex_smooth = tex_smooth;
    imgs_filtered.tex_bg_smooth = tex_bg_smooth;
    imgs_filtered.tex_bs = tex_bs;
        
    % remove pixels that have non-grayish texture in the current image
    r_tex = tex_smooth(:,:,1);
    g_tex = tex_smooth(:,:,2);
    b_tex = tex_smooth(:,:,3);
    rg_thr = 0.11;
    gb_thr = 0.11;
    rb_thr = 0.11;
    tex_gray_px = abs(r_tex-g_tex)<rg_thr & abs(r_tex-b_tex)<rb_thr & abs(g_tex-b_tex)<gb_thr;
    img_bs_rmColorTex = img_bs_rmLowDoGdiff;
    img_bs_rmColorTex(~repmat(tex_gray_px,1,1,3)) = 0;
    
    imgs_filtered.tex_gray_px = tex_gray_px;
    imgs_filtered.img_bs_rmColorTex = img_bs_rmColorTex;

    % remove pixels that have low background subtraction of DoG of textures
    tex_DoG = diffOfGaussian(tex_smooth,0.5,3);
    tex_bg_DoG = diffOfGaussian(tex_bg_smooth,0.5,3);
    tex_DoGdiff = mat2gray(backgroundSubtraction(tex_DoG,tex_bg_DoG,'Normalize'));
    r_thr = 0.05;
    g_thr = 0.05;
    b_thr = 0.05;
    tex_DoGdiff_thr = tex_DoGdiff(:,:,1)>r_thr & tex_DoGdiff(:,:,2)>g_thr & tex_DoGdiff(:,:,3)>b_thr;
    tex_DoGdiff_entropy_px = entropyfilt(tex_DoGdiff_thr,true(9,9));
    tex_DoGdiff_entropy_px = im2bw(tex_DoGdiff_entropy_px,0.75);
    img_bs_rmLowDoGTexdiff = img_bs_rmColorTex;
    img_bs_rmLowDoGTexdiff(~repmat(tex_DoGdiff_entropy_px,1,1,3)) = 0;
    
    imgs_filtered.tex_DoG = tex_DoG;
    imgs_filtered.tex_bg_DoG = tex_bg_DoG;
    imgs_filtered.tex_DoGdiff = tex_DoGdiff;
    imgs_filtered.tex_DoGdiff_thr = tex_DoGdiff_thr;
    imgs_filtered.tex_DoGdiff_entropy_px = tex_DoGdiff_entropy_px;
    imgs_filtered.img_bs_rmLowDoGTexdiff = img_bs_rmLowDoGTexdiff;
   
    % create a mask
    img_bs_mask_gray = rgb2gray(img_bs_rmLowDoGTexdiff);
    img_bs_mask = false(size(img_bs_mask_gray));
    img_bs_mask(img_bs_mask_gray>0) = true;

    imgs_filtered.img_bs_mask = img_bs_mask;

    % smooth the mask
    img_bs_mask_smooth = img_bs_mask;
    img_bs_mask_smooth = im2double(morphology(img_bs_mask_smooth,5,'close'));

    imgs_filtered.img_bs_mask_smooth = img_bs_mask_smooth;

    % remove noise
    img_bs_mask_clean = img_bs_mask_smooth;
    img_bs_mask_clean = removeNoise(img_bs_mask_clean);
    img_bs_mask_clean = removeSmallRegions(img_bs_mask_clean,50);

    imgs_filtered.img_bs_mask_clean = img_bs_mask_clean;
end