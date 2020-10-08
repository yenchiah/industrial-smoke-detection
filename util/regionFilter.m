function [ BRF,imgs_BRF ] = regionFilter( img,TS,imgs_IICD,HFCD_IICD,img_bg )
    % remove segments which do not have correct shapes
    tex_seg_shape = removeRegions(TS,'nonRect',2.5,[],0.4);

    % group white and black color segments
    img_adj = imadjustRGB(img);
    tex_seg_group = groupRegions(tex_seg_shape,'white',img_adj,0.5);
    tex_seg_group = groupRegions(tex_seg_group,'black',img_adj,0.3);
    
    % remove nongray regions
    tex_seg_gray = removeRegions(tex_seg_group,'nonGray',[0.18 0.18 0.32],imgs_IICD.img_histeq);
    
    % remove too large and too small regions
    tex_seg_size = removeRegions(tex_seg_gray,'largerLabel',numel(img(:,:,1))*0.2);
    tex_seg_size = removeRegions(tex_seg_size,'smaller',200);
    
    % remove segments which do not have enough changes
    tex_seg_change = removeRegions(tex_seg_size,'noChangeWhiteLabel',0.7,img_adj,0.6,HFCD_IICD);
    tex_seg_change = removeRegions(tex_seg_change,'noChange',0.5,HFCD_IICD);
    tex_seg_change = removeRegions(tex_seg_change,'smaller',20);
    
    % remove white labels
    tex_seg_nonwhite = removeRegions(tex_seg_change,'white',0.9,img_adj);
    
    % remove shadow
    img_bs = backgroundSubtraction(img,img_bg,'Normalize');
    tex_seg_nonshadow = removeRegions(tex_seg_nonwhite,'shadow',[0.09,1],img_bs,0.5,img);
%     tex_seg_nonshadow = removeRegions(tex_seg_nonwhite,'shadow',[0.05,1],img_bs,0.5,img);
    
    % return images
    imgs_BRF.tex_seg_shape = tex_seg_shape;
    imgs_BRF.img_adj = img_adj;
    imgs_BRF.tex_seg_group = tex_seg_group;
    imgs_BRF.tex_seg_gray = tex_seg_gray;
    imgs_BRF.tex_seg_size = tex_seg_size;
    imgs_BRF.tex_seg_change = tex_seg_change;
    imgs_BRF.tex_seg_nonwhite = tex_seg_nonwhite;
    imgs_BRF.img_bs = img_bs;
    imgs_BRF.tex_seg_nonshadow = tex_seg_nonshadow;
    BRF = im2bw(tex_seg_nonshadow,0);
end

