function imgs_out = LCN( imgs )
	% local contrast normalization
    imgs_out = zeros(size(imgs));
    imgs = double(imgs);
    for i=1:size(imgs,4)
        for j=1:size(imgs,3)
            channel = imgs(:,:,j,i);
            local_mean = conv2(channel,ones(3)/9,'same');
            local_var = stdfilt(channel).^2;
            imgs_out(:,:,j,i) = (channel-local_mean)./local_var;
        end
    end
end

