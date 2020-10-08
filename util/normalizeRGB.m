function img_normalized = normalizeRGB( img )
    img_normalized = img./repmat(sum(img,3),1,1,3);
end
