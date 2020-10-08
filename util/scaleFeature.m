function [ feature_out,feature_max,feature_min ] = scaleFeature( feature )
    % scale data to range [0,1]
    % 1. avoid features in greater ranges dominating those in smaller ones
    % 2. avoid numerical difficulties during the calculation
    feature_max = max(feature);
    feature_min = min(feature);
    feature_out = normalizeFeature(feature,feature_max,feature_min);
end

