function feats = textureEnergy( img )
    % compute Laws' texture energy
    % create 1D masks
    ks = [ ...
        [1,4,6,4,1]; ... %L5
    	[1,-2,0,2,1]; ... %E5
        [-1,0,2,0,-1]; ... %S5
        [-1,2,0,-2,1]; ... %W5
        [1,-4,6,-4,1]; ... % R5
    ];
    % stack of outer products
    kstack = zeros(5,5,25);
    k = 1;
    for i = 1:5
        for j= 1:5
            kstack(:,:,k) = ks(i,:)' * ks(j,:);
            k = k + 1;
        end
    end

    % read in image and init variables
    imgtxture = double(img);
    feats = zeros([size(imgtxture) 25]);
    egy = @(x) sum(abs(x(:)));

    % prep normalize image
    d = 15; % side of processing block
    imnorm = conv2(imgtxture,kstack(:,:,1),'same');
    imnormT = nlfilter(imnorm,[d d],egy);

    % fill in the feats array
    feats(:,:,1) = imnormT;
    for kfeat = 2:25
        feats(:,:,kfeat) = nlfilter(conv2(imgtxture,kstack(:,:,kfeat),'same'),[d d],egy);
        feats(:,:,kfeat) = feats(:,:,kfeat)./imnormT;
    end
end

