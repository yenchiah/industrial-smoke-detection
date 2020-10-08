function [ TS,imgs_TS ] = textureSegmentation( img,filter_bank,K )
    % texture segmentation using the provided filter bank
    % normalize image
    img_normalized = double(img);
%     img_normalized = normalizeRGB(img_normalized);
    for i=1:size(img,3)
        channel = img_normalized(:,:,i);
        img_normalized(:,:,i) = (channel - mean(channel(:)))./255;
    end
    
    % compute texture features using the filter bank
    feature = zeros([size(img,1),size(img,2),size(filter_bank,3)*3]);
    for k=1:size(filter_bank,3)
        feature(:,:,k*3-2:k*3) = mat2gray(imfilter(img_normalized,filter_bank(:,:,k),'same','conv','replicate'));
    end
    size_origin = size(feature);
    feature = single(reshape(feature,[],size(feature,3)));
    
    % principal component analysis
    [coeff,~,latent] = pca(feature);
    ratio = 0.98;
    bound = ratio*sum(latent);
    accum = 0;
    for p=1:numel(latent)
        accum = accum + latent(p);
        if(accum >= bound)
            break;
        end
    end
    coeff = coeff(:,1:p);
    feature = feature*coeff;
    
    % k-means clustering
    [~,idx] = vl_kmeans(feature',K,'maxNumIterations',5,'algorithm','elkan','initialization','plusplus','NumRepetitions',5);
    tex_seg = uint8(reshape(idx,size_origin(1),size_origin(2)));
    
    % smooth the texture image
    tex_seg_smooth = removeRegions(tex_seg,'smaller',10);
    tex_seg_smooth = removeLabelNoise(tex_seg_smooth);
    tex_seg_smooth = removeRegions(tex_seg_smooth,'smaller',80);
    tex_seg_smooth = morphology(tex_seg_smooth,2,'close');

    % return images
    imgs_TS.tex_seg = tex_seg;
    TS = tex_seg_smooth;
end

