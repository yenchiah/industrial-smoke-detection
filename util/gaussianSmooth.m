function imgs_smooth = gaussianSmooth( imgs,sigma )
    imgs_smooth = imgs;
    h_size = 2*ceil(3*sigma)+1;
    h = fspecial('gaussian',[h_size h_size],sigma);
    for i=1:size(imgs,4)
        for j=1:size(imgs,3)
            imgs_smooth(:,:,j,i) = imfilter(imgs(:,:,j,i),h,'same');
        end
    end
end

