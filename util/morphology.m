function [ img_morph ] = morphology( img,level,option )
    channel = cell(1,1,size(img,3));
    se = strel('disk',level);
    for i=1:size(img,3)
        img_c = img(:,:,i);
        if(strcmp(option,'close'))
            img_c = imclose(im2uint8(img_c),se);
        elseif(strcmp(option,'open'))
            img_c = imopen(im2uint8(img_c),se);
        end
        channel{i} = img_c;
    end
    img_morph = cell2mat(channel);
end

