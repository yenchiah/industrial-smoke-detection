function data_out = normalizeData( data )
    data_out = double(data);
    for i=1:size(data,3)
        channel = double(data(:,:,i,1));
        channel = (channel-mean(channel(:)))./255;
        data_out(:,:,i,1) = channel;
    end
    data_out = permute(data_out,[2 1 3 4]);
end

