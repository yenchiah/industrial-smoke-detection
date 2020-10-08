function imgs_DoG = diffOfGaussian( imgs,sigma,K )
    sigma1 = sigma;
    sigma2 = sigma*K;
    imgs_DoG = gaussianSmooth(imgs,sigma1) - gaussianSmooth(imgs,sigma2);
    imgs_DoG = im2double(imgs_DoG);
end