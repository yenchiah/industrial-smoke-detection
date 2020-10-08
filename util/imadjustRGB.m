function imgs_adj = imadjustRGB( imgs )
    imgs_adj = double(imgs);
    for i=1:size(imgs,4)
        img = imgs(:,:,:,i);
        img(:,:,1) = imadjust(img(:,:,1),stretchlim(img(:,:,1)));
        img(:,:,2) = imadjust(img(:,:,2),stretchlim(img(:,:,2)));
        img(:,:,3) = imadjust(img(:,:,3),stretchlim(img(:,:,3)));
%         img = rgb2hsv(img);
%         img(:,:,3) = imadjust(img(:,:,3));
%         img = hsv2rgb(img);
        imgs_adj(:,:,:,i) = mat2gray(img);
    end
end