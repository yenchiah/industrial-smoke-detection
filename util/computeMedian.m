function imgs_median = computeMedian( imgs,range,use_gpu_array,date )
    num_frames = size(imgs,3);
    imgs_median = zeros(size(imgs,1),size(imgs,2),num_frames,'uint8');
    ptr_end = range;
    if(use_gpu_array)
        pool = gpuArray(imgs(:,:,1:range));
    else
        pool = imgs(:,:,1:range);
    end
    for t=1:num_frames
        fprintf('Processing frame %d using range = %d of %s\n',t,range,date);
        if t > range && t < num_frames-range+1
            ptr_end = ptr_end + 1;
            pool = circshift(pool,-1,3);
            pool(:,:,end) = imgs(:,:,ptr_end);
        end
        if(use_gpu_array)
            imgs_median(:,:,t) = gather(median(pool,3));
        else
            imgs_median(:,:,t) = median(pool,3);
        end
    end
end