function img_clean = removeNoise( img )
    channel = cell(1,1,size(img,3));
    for i=1:size(img,3)
        img_c = img(:,:,i);
        img_c = medfilt2(im2uint8(img_c),[3 3]);
        channel{i} = img_c;
    end
    img_clean = cell2mat(channel);
end

