function img_out = eraseImgBorder( img,border )
    img_out = img;
    img_out(1:border,:,:) = 0;
    img_out(end-border+1:end,:,:) = 0;
    img_out(:,1:border,:) = 0;
    img_out(:,end-border+1:end,:) = 0;
end

