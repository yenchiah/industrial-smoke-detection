function [ feature,dimension ] = computeFeature( img,img_bg,img_pre,img_pre2,plot_graph )
    narginchk(0,5)
    nargoutchk(1,2)
    
    dimension = 588;
    
    if(nargin==0)
        feature = 0;
        return;
    elseif(nargin==4)
        plot_graph = false;
    end

    feature = zeros(1,dimension);
    
    ptr = 1;
    
    % compute distribution features
    img_bs = im2uint8(mat2gray(backgroundSubtraction(img,img_bg,'Normalize')));
    img_fd = im2uint8(mat2gray(backgroundSubtraction(img,img_pre,'Normalize')));
    img_fd2 = im2uint8(mat2gray(backgroundSubtraction(img,img_pre2,'Normalize')));
    
    f_bs = cell(3,1);
    f_fd = cell(3,1);
    f_fd2 = cell(3,1);
    x = 1:64;
    for j=1:3
        edges = 0:4:256;
        [f_bs{j},~] = histcounts(img_bs(:,:,j),edges,'Normalization','probability');
        [f_fd{j},~] = histcounts(img_fd(:,:,j),edges,'Normalization','probability');
        [f_fd2{j},~] = histcounts(img_fd2(:,:,j),edges,'Normalization','probability');
    end
    
    feature(1,ptr:ptr+numel(f_bs{1})*9-1) = [f_bs{1},f_bs{2},f_bs{3},f_fd{1},f_fd{2},f_fd{3},f_fd2{1},f_fd2{2},f_fd2{3}];
    
    ptr = ptr + numel(f_bs{1})*9;
    
    if(plot_graph)
        x_lim = [min(x)-1,max(x)+1];
        % visualize distributions
        figure(99);
        img_cols = 3;
        img_rows = 3;

        subplot(img_rows,img_cols,1);
        bar(x,f_bs{1})
        xlim(x_lim)
        
        subplot(img_rows,img_cols,2);
        bar(x,f_bs{2})
        xlim(x_lim)
        
        subplot(img_rows,img_cols,3);
        bar(x,f_bs{3})
        xlim(x_lim)
        
        subplot(img_rows,img_cols,4);
        bar(x,f_fd{1})
        xlim(x_lim)
        
        subplot(img_rows,img_cols,5);
        bar(x,f_fd{2})
        xlim(x_lim)
        
        subplot(img_rows,img_cols,6);
        bar(x,f_fd{3})
        xlim(x_lim)
        
        subplot(img_rows,img_cols,7);
        bar(x,f_fd2{1})
        xlim(x_lim)
        
        subplot(img_rows,img_cols,8);
        bar(x,f_fd2{2})
        xlim(x_lim)
        
        subplot(img_rows,img_cols,9);
        bar(x,f_fd2{3})
        xlim(x_lim)
    end
    
    % compute image features
    img_DoG = mat2gray(diffOfGaussian(img,0.5,3));
    img_bg_DoG = mat2gray(diffOfGaussian(img_bg,0.5,3));
    img_pre_DoG = mat2gray(diffOfGaussian(img_pre,0.5,3));
    img_pre2_DoG = mat2gray(diffOfGaussian(img_pre2,0.5,3));
    
    border = 3;
    img_DoG = eraseImgBorder(img_DoG,border);
    img_bg_DoG = eraseImgBorder(img_bg_DoG,border);
    img_pre_DoG = eraseImgBorder(img_pre_DoG,border);
    img_pre2_DoG = eraseImgBorder(img_pre2_DoG,border);
    
    feature(1,ptr:ptr+11) = [...
        squeeze(sum(sum(img_DoG)))',...
        squeeze(sum(sum(img_bg_DoG)))',...
        squeeze(sum(sum(img_pre_DoG)))',...
        squeeze(sum(sum(img_pre2_DoG)))'...
        ];

    if(plot_graph)
        % visualize images
        figure(100);
        img_cols = 4;
        img_rows = 2;
        fig_idx = 1;
        option = 'smallGraph';

        I = img;
        str = 'img';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = img_bg;
        str = 'img-bg';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = img_pre;
        str = 'img-pre';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = img_pre2;
        str = 'img-pre2';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = img_DoG;
        str = 'img-DoG';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = img_bg_DoG;
        str = 'img-bg-DoG';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = img_pre_DoG;
        str = 'img-pre-DoG';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = img_pre2_DoG;
        str = 'img-pre2-DoG';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);
    end
end

