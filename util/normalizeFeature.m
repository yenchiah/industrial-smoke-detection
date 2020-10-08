function [ feature_out ] = normalizeFeature( feature,feature_max,feature_min )
    n = size(feature,1);
    feature_max_mat = repmat(feature_max,n,1);
    feature_min_mat = repmat(feature_min,n,1);
    feature_out = (feature-feature_min_mat)./(feature_max_mat-feature_min_mat);
end

