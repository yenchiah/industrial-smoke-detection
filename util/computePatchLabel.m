function patch_label = computePatchLabel( label_img,patch_size,patch_shift )
    if(sum(label_img(:))>0)
        h = ones(patch_size,patch_size);
        patch_label = filter2(h,label_img,'valid');
        patch_label = patch_label(1:patch_shift:end,1:patch_shift:end);
        patch_label = patch_label/patch_size^2;
    else
        [height,width] = computePatchLabelSize(size(label_img),patch_size,patch_shift);
        patch_label = zeros(height,width);
    end
    patch_label = patch_label(:);
end

