function imgs_edge = edgeRGB( imgs )
    imgs_edge = zeros(size(imgs));
    for i=1:size(imgs,4)
        for j=1:size(imgs,3)
            imgs_edge(:,:,j,i) = imgradient(imgs(:,:,j,i),'Sobel');
        end
    end
end

