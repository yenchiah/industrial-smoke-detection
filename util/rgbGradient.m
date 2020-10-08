function G = rgbGradient( imgs )
    G = imgs;
    for i=1:size(imgs,4)
        for j=1:size(imgs,3)
            G(:,:,j,i) = imgradient(imgs(:,:,j,i));
        end
    end
end

