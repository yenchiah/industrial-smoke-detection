function [ tiles,num_tiles ] = img2Tiles( img )
    narginchk(0,1)
    
    num_row_tiles = 4;
    num_col_tiles = 4;
    num_tiles = num_row_tiles*num_col_tiles+(num_row_tiles-1)*(num_col_tiles-1);
    
    if(nargin==0)
        tiles = 0;
        return;
    end

    row_size = round(size(img,1)/num_row_tiles);
    col_size = round(size(img,2)/num_col_tiles);
    
    % type I tiles
    tiles_1 = mat2cell(img,...
        [ones(1,num_row_tiles-1)*row_size,size(img,1)-(num_row_tiles-1)*row_size],...
        [ones(1,num_col_tiles-1)*col_size,size(img,2)-(num_col_tiles-1)*col_size],...
        size(img,3));
    
    % type II tiles
    span_row = size(img,1) - row_size*(num_row_tiles-1);
    span_row_left = round(span_row/2);
    span_row_right = span_row - span_row_left;
    span_col = size(img,2)-col_size*(num_col_tiles-1);
    span_col_top = round(span_col/2);
    span_col_bottom = span_col - span_col_top;
    tiles_2 = mat2cell(img(span_row_left+1:end-span_row_right,span_col_top+1:end-span_col_bottom,:),...
        ones(1,num_row_tiles-1)*row_size,...
        ones(1,num_col_tiles-1)*col_size,...
        size(img,3));
    
    tiles = [tiles_1(:);tiles_2(:)];
end

