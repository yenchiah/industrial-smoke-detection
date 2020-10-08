function [ idx_start,idx_end ] = computeSegments( vector )
    vector_diff = diff(vector);
    idx_start = find(vector_diff==1)+1;
    idx_end = find(vector_diff==-1);
end