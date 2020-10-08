function [val,imgs_filtered] = detectSmoke2( img,img_bg,filter_bank )
	% local contrast normalization
    img_lcn = mat2gray(localnormalize(double(gaussianSmooth(img,0.5)),128,128));
    img_bg_lcn = mat2gray(localnormalize(double(gaussianSmooth(img_bg,0.5)),128,128));

    % color adjustment
    img_adj = imadjustRGB(img);

    % histogram equalization
    img_histeq = histeqRGB(img);
    img_bg_histeq = histeqRGB(img_bg);
    
    % normalize image
    img_normalized = double(img_histeq);
    for i=1:size(img,3)
        channel = img_normalized(:,:,i);
        img_normalized(:,:,i) = (channel - mean(channel(:)))./255;
    end
    
    % compute texture features using the filter bank
    feature = zeros([size(img,1),size(img,2),size(filter_bank,3)*3]);
    for k=1:size(filter_bank,3)
        feature(:,:,k*3-2:k*3) = mat2gray(imfilter(img_normalized,filter_bank(:,:,k),'same','conv','replicate'));
    end
    size_origin = size(feature);
    feature = single(reshape(feature,[],size(feature,3)));
    
    % principal component analysis
    [coeff,~,latent] = pca(feature);
    ratio = 0.98;
    bound = ratio*sum(latent);
    accum = 0;
    for p=1:numel(latent)
        accum = accum + latent(p);
        if(accum >= bound)
            break;
        end
    end
    coeff = coeff(:,1:p);
    feature = feature*coeff;

    % k-means clustering
    K = 20;
    [~,idx] = vl_kmeans(feature',K,'maxNumIterations',5,'algorithm','elkan','initialization','plusplus','NumRepetitions',5);
    tex_seg = uint8(reshape(idx,size_origin(1),size_origin(2)));
    
    % filter the texture image
    tex_seg_filtered = removeSmallRegions(tex_seg,30);
    tex_seg_filtered = removeLabelNoise(tex_seg_filtered);
    tex_seg_filtered = removeSmallRegions(tex_seg_filtered,50);
    
    % remove non-grayish segments
    tex_seg_rm_nongray = tex_seg_filtered;
    r = img_histeq(:,:,1);
    g = img_histeq(:,:,2);
    b = img_histeq(:,:,3);
    rg_thr = 0.1;
    gb_thr = 0.1;
    rb_thr = 0.2;
    img_gray_px = abs(r-g)<rg_thr & abs(r-b)<rb_thr & abs(g-b)<gb_thr;
    tex_seg_rm_nongray(~img_gray_px) = 0;
    tex_seg_rm_nongray_filtered = removeSmallRegions(tex_seg_rm_nongray,25);
    tex_seg_rm_nongray_filtered = morphology(tex_seg_rm_nongray_filtered,2,'close');

    % remove non-black segments
    tex_seg_rm_nonblack = tex_seg_rm_nongray_filtered;
    r = img_adj(:,:,1);
    g = img_adj(:,:,2);
    b = img_adj(:,:,3);
    r_thr = 0.5;
    g_thr = 0.5;
    b_thr = 0.7;
    img_black_px = r<r_thr & g<g_thr & b<b_thr;
    tex_seg_rm_nonblack(~img_black_px) = 0;
    tex_seg_rm_nonblack_filtered = removeLabelNoise(tex_seg_rm_nonblack);
    tex_seg_rm_nonblack_filtered = morphology(tex_seg_rm_nonblack_filtered,2,'close');
    tex_seg_rm_nonblack_filtered = removeSmallRegions(tex_seg_rm_nonblack_filtered,50);
    
    % remove pixels that have non-black and non-white texture in the current image
    tex_seg_rm_highfreq = tex_seg_rm_nonblack_filtered;
    img_DoG = mat2gray(abs(diffOfGaussian(img_lcn,0.5,3)));
    img_entropy = mat2gray(entropyfilt(img_DoG,true(9,9)));
    img_entropy = bilateralSmooth(img_entropy,0.2,10);
    r = img_entropy(:,:,1);
    g = img_entropy(:,:,2);
    b = img_entropy(:,:,3);
    r_whi_thr = 0.4;
    g_whi_thr = 0.4;
    b_whi_thr = 0.5;
    r_bla_thr = 0.5;
    g_bla_thr = 0.5;
    b_bla_thr = 0.65;
    rg_thr = 0.1;
    gb_thr = 0.1;
    rb_thr = 0.1;
    img_entropy_white_px = r>r_whi_thr & g>g_whi_thr & b>b_whi_thr;
    img_entropy_black_px = r<r_bla_thr & g<g_bla_thr & b<b_bla_thr;
    img_entropy_gray_px = abs(r-g)<rg_thr & abs(r-b)<rb_thr & abs(g-b)<gb_thr;
    tex_seg_rm_highfreq(~(img_entropy_white_px | img_entropy_black_px | img_entropy_gray_px)) = 0;
    
    % image morphology and smoothing
    tex_seg_clean = im2bw(mat2gray(tex_seg_rm_highfreq),0);
    tex_seg_clean = removeLabelNoise(tex_seg_clean);
	tex_seg_clean = removeSmallRegions(tex_seg_clean,300);
    
    % background subtraction of images
    img_bs = backgroundSubtraction(img_histeq,img_bg_histeq,'Normalize');
    
    % threshold the background subtraction of images
    thr = 0.1;
    img_bs_thr = im2bw(img_bs,thr);
    img_bs_thr = morphology(img_bs_thr,2,'close');
    img_bs_thr = removeLabelNoise(img_bs_thr);
    
    % background subtraction of DoG
    img_bg_DoG = mat2gray(abs(diffOfGaussian(img_bg_lcn,0.5,3)));
    img_bs_DoG = mat2gray(backgroundSubtraction(img_DoG,img_bg_DoG,'Normalize'));
    
    % finalize the result
    img_smoke = tex_seg_clean & img_bs_thr;
    
    % smooth the result
    img_smoke_clean = morphology(img_smoke,2,'close');
    img_smoke_clean = removeSmallRegions(img_smoke_clean,200);
    img_smoke_clean = im2bw(img_smoke_clean,0);

    % return images
    imgs_filtered.img_lcn = img_lcn;
    imgs_filtered.img_adj = img_adj;
    imgs_filtered.img_histeq = img_histeq;
    imgs_filtered.tex_seg = tex_seg;
    imgs_filtered.tex_seg_filtered = tex_seg_filtered;
    imgs_filtered.img_gray_px = img_gray_px;
    imgs_filtered.tex_seg_rm_nongray = tex_seg_rm_nongray;
    imgs_filtered.tex_seg_rm_nongray_filtered = tex_seg_rm_nongray_filtered;
    imgs_filtered.img_black_px = img_black_px;
    imgs_filtered.tex_seg_rm_nonblack = tex_seg_rm_nonblack;
    imgs_filtered.tex_seg_rm_nonblack_filtered = tex_seg_rm_nonblack_filtered;
    imgs_filtered.img_DoG = img_DoG;
    imgs_filtered.img_entropy = img_entropy;
    imgs_filtered.img_entropy_white_px = img_entropy_white_px;
    imgs_filtered.img_entropy_black_px = img_entropy_black_px;
    imgs_filtered.img_entropy_gray_px = img_entropy_gray_px;
    imgs_filtered.tex_seg_rm_highfreq = tex_seg_rm_highfreq;
    imgs_filtered.tex_seg_clean = tex_seg_clean;
    imgs_filtered.img_bg_DoG = img_bg_DoG;
    imgs_filtered.img_bs_DoG = img_bs_DoG;
    imgs_filtered.img_bs = img_bs;
    imgs_filtered.img_bs_thr = img_bs_thr;
    imgs_filtered.img_smoke = img_smoke;
    imgs_filtered.img_smoke_clean = img_smoke_clean;
    val = sum(img_smoke_clean(:));
end