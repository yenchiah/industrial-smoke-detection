function signal_out = filter1D( signal,sigma )
    h = fspecial('gaussian',[2*ceil(3*sigma)+1 1],sigma);
    signal_out = imfilter(signal,h,'same');
end