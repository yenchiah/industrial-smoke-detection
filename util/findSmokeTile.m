function flag = findSmokeTile( tile )
    flag = 0;
    num_smoke_px = sum(sum(tile));
    if(num_smoke_px/numel(tile)>0.3)
        flag = 1;
    end
end

