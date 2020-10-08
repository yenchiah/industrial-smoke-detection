function imgs_hsv = rgb2hsv_4D( imgs )
    imgs_hsv = double(imgs);
    for i=1:size(imgs,4)
        imgs_hsv(:,:,:,i) = rgb2hsv(imgs(:,:,:,i));
    end
end

