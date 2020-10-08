clear all;
addpath(genpath('libs'));
addpath(genpath('util'));

filter_bank = getFilterbank();
filter_bank = permute(filter_bank, [1 2 4 3]);
imdisp(filter_bank,'Border',[0.02,0.03],'Size',[2,13],'Map','gray')