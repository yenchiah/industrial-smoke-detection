function feature = computePatchData( imgs,patch_size,patch_shift )
    %% image smoothing
    imgs_smooth = imgs;
    imgs_smooth{end} = gaussianSmooth(imgs{end},0.5);
    imgs_smooth{end-1} = gaussianSmooth(imgs{end-1},0.5);
    imgs_smooth{end-2} = gaussianSmooth(imgs{end-2},0.5);

    %% convert to hsv
    imgs_hsv = imgs_smooth;
    imgs_hsv{end} = rgb2hsv(imgs_smooth{end});
    imgs_hsv{end-1} = rgb2hsv(imgs_smooth{end-1});
    imgs_hsv{end-2} = rgb2hsv(imgs_smooth{end-2});

    %% three frame differencing
    imgs_diff_hsv = threeFrameDiff(imgs_hsv);

    %% compute difference of Gaussian
    imgs_DoG = imgs;
    sigma = 0.5;
    K = 3;
    imgs_DoG{end} = diffOfGaussian(imgs{end},sigma,K);
    imgs_DoG{end-1} = diffOfGaussian(imgs{end-1},sigma,K);
    imgs_DoG{end-2} = diffOfGaussian(imgs{end-2},sigma,K);
    img_bg_DoG = diffOfGaussian(img_bg,sigma,K);

    %% three frame differencing of DoG
    img_DoG_diff = threeFrameDiff(imgs_DoG,'noNormalization');

    %% compute entropy image
    img_eny = entropyfilt(imgs_diff_hsv(:,:,3),ones(9));

    feature = zeros(5,2590);
end

