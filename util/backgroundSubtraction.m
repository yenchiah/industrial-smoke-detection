function img_bs = backgroundSubtraction( img,img_bg,option )
    narginchk(2,3);
    img = double(img);
    img_bg = double(img_bg);
    if(nargin == 3 && strcmp(option,'Normalize'))
        img_bs = abs(img_bg-img)./max(img_bg+img,0.1);
    elseif(nargin == 3 && strcmp(option,'NormalizeWithSign'))
        img_bs = (img_bg-img)./max(img_bg+img,0.1);
    else
        img_bs = abs(img_bg-img);
    end
    img_bs(isnan(img_bs)) = 0;
end