function [ bbox_row,bbox_col ] = selectBound( img )
    figure
    mask = roipoly(img);
    stats = regionprops(mask,'BoundingBox');
    bbox = round(stats.BoundingBox);
    bbox_col = bbox(1):bbox(1)+bbox(3);
    bbox_row = bbox(2):bbox(2)+bbox(4);
end

