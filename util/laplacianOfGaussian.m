function imgs_out = laplacianOfGaussian( imgs,sigma )
    imgs_out = imgs;
    h_size = 2*ceil(3*sigma)+1;
    h = fspecial('log',[h_size h_size],sigma);
    for i=1:size(imgs,4)
        for j=1:size(imgs,3)
            imgs_out(:,:,j,i) = imfilter(imgs(:,:,j,i),h,'same');
        end
    end
end

