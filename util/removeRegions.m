function label_clean = removeRegions( label,option,thr1,img,thr2,img2 )
    narginchk(3,6)
    channel_idx = unique(label);
    channel_idx(channel_idx==0) = [];
    label_clean = zeros(size(label),'uint8');
    if(nargin>=4 && size(img,3)>1)
        r = img(:,:,1);
        g = img(:,:,2);
        b = img(:,:,3);
%         gray = rgb2gray(img);
    end
%     if(nargin>=6 && size(img2,3)>1)
%         gray2 = rgb2gray(img2);
%     end
    for c=1:numel(channel_idx)
        channel = (label==channel_idx(c));
        if(strcmp(option,'noChangeWhiteLabel'))
            idx = find(channel~=0);
            if(median(r(idx))>thr1 && median(g(idx))>thr1 && median(b(idx))>thr1 && sum(img2(idx))/numel(idx)<thr2)
                channel(idx) = 0;
            end
        elseif(strcmp(option,'largerLabel'))
            idx = find(channel~=0);
            if(numel(idx)>thr1)
                channel(idx) = 0;
            end
        elseif(strcmp(option,'smallerLabel'))
            idx = find(channel~=0);
            if(numel(idx)<thr1)
                channel(idx) = 0;
            end
        else
            CC = bwconncomp(channel);
            if(strcmp(option,'nonRect'))
                stats = regionprops(CC,'BoundingBox');
            end
            for i=1:CC.NumObjects
                idx = CC.PixelIdxList{i};
                if(strcmp(option,'smaller'))
                    if(numel(idx)<thr1)
                        channel(idx) = 0;
                    end
                elseif(strcmp(option,'larger'))
                    if(numel(idx)>thr1)
                        channel(idx) = 0;
                    end
                elseif(strcmp(option,'largerAndWhiter'))
                    if(numel(idx)>thr1 && median(r(idx))>thr2 && median(g(idx))>thr2 && median(b(idx))>thr2)
                        channel(idx) = 0;
                    end
                elseif(strcmp(option,'white'))
                    if(median(r(idx))>thr1 && median(g(idx))>thr1 && median(b(idx))>thr1)
                        channel(idx) = 0;
                    end
                elseif(strcmp(option,'nonGray'))
                    median_r = median(r(idx));
                    median_g = median(g(idx));
                    median_b = median(b(idx));
                    if(abs(median_r-median_g)>thr1(1) || abs(median_g-median_b)>thr1(2) || abs(median_r-median_b)>thr1(3))
                        channel(idx) = 0;
                    end
                elseif(strcmp(option,'noChange'))
                    if(sum(img(idx))/numel(idx)<thr1)
                        channel(idx) = 0;
                    end
                elseif(strcmp(option,'shadow'))
                    % kernel density estimation
                    [f,xi] = ksdensity(img(idx),'bandwidth',0.01,'npoints',100);
                    % find local max
                    min_peak_prominence = 0.05;
                    min_peak_height = 2;
                    min_peak_distance = 0;
                    thr = 0;
                    max_peak_width = 100;
                    [pks,locs,~,~] = findpeaks(f,'MinPeakProminence',min_peak_prominence,'MinPeakHeight',min_peak_height,'MinPeakDistance',min_peak_distance,'Threshold',thr,'MaxPeakWidth',max_peak_width);
                    if(numel(pks)==0)
                        return;
                    end
                    intensity = double(median(img2(idx)))/255;
                    pks_thr = [];
                    locs_thr = [];
                    [pks_max, idx_max] = max(pks);
                    locs_max = locs(idx_max);
                    thr = max(pks)*0.55;
                    for k=1:numel(pks)
                        if(pks(k)>thr)
                            pks_thr(end+1) = pks(k);
                            locs_thr(end+1) = locs(k);
                        end
                    end
                    if(xi(locs_max)>=thr1(1) && numel(pks_thr)<=thr1(2) && intensity<=thr2)
                        channel(idx) = 0;
                    end
%                     figure
%                     plot(xi,f)
%                     xlim([-0.1 0.7])
%                     hold on
%                     plot(xi(locs_thr),pks_thr,'ro')
%                     hold on
%                     plot([-0.1,0.7],[thr,thr],'r--','LineWidth',1)
%                     hold on
%                     plot([xi(locs_max),xi(locs_max)],[0,pks_max],'r--','LineWidth',1)
%                     hold off
                elseif(strcmp(option,'nonRect'))
                    bbox = stats(i).BoundingBox;
                    if(bbox(3)/bbox(4)>thr1 && numel(idx)/(bbox(3)*bbox(4))>thr2)
                        channel(idx) = 0;
                    elseif(bbox(3)/bbox(4)>thr1*1.5)
                        channel(idx) = 0;
                    end
                end
            end
        end
        label_clean(channel~=0) = channel_idx(c);
    end
end

