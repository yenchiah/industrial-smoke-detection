function diff = rgbDiff( img )
    r = img(:,:,1);
    g = img(:,:,2);
    b = img(:,:,3);
    diff = sum(sum(abs(r-g)+abs(r-b)+abs(g-b)));
end

