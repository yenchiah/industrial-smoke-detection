function [ responses,imgs_filtered ] = computeFeature( img )
    % convert to hsv
    imgs_hsv = rgb2hsv(img);
    imgs_filtered.img_s = imgs_hsv(:,:,2);
    responses.img_s = sum(imgs_filtered.img_s(:));
    
    % compute difference of Gaussian
    img_lcn = mat2gray(localnormalize(double(gaussianSmooth(img,0.5)),128,128));
    img_DoG = mat2gray(abs(diffOfGaussian(img_lcn,0.5,3)));
    imgs_filtered.img_DoG = img_DoG;
    responses.img_DoG = sum(img_DoG(:));
end