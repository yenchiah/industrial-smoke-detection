function imgs_histeq = histeqRGB( imgs )
    imgs_histeq = double(imgs);
    for i=1:size(imgs,4)
        img = imgs(:,:,:,i);
        img = rgb2hsv(img);
        img(:,:,3) = adapthisteq(img(:,:,3));
        img = hsv2rgb(img);
        imgs_histeq(:,:,:,i) = img;
    end
end

