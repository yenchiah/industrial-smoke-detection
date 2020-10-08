function [ height,width ] = computePatchLabelSize( img_size,patch_size,patch_shift )
    width = ((img_size(2)-patch_size)/patch_shift)+1;
    height = ((img_size(1)-patch_size)/patch_shift)+1;
end

