echo on


mask_gm = loadsome('matlab', 'seeds_cortical');
mask_slf_a = close_mask(ismember(mask_gm, [1027 1028     ]), 5);
mask_slf_b = close_mask(ismember(mask_gm, [1008 1029 1031]), 5);

% [nx ny nz] = size(mask_slf_a);
% [xx yy zz] = ndgrid(1:nx, 1:ny, 1:nz);
% mask_A = yy <  50 & xx >= 72;
% mask_B = yy > 100 & xx >= 72;

% fn = 'lmi/tmi/slf/slf_2T';

% ff2 = connect(ff);
ff_ = connecting(ff2, mask_slf_a, mask_slf_b, mask_slf_win); numel(ff_)
fn
ijk2tube(ff_, fn);



echo off
return


ff_DT_ = connecting(connect(ff_DT), mask_slf_a, mask_slf_b, mask_slf_win); numel(ff_DT_)
ijk2tube(ff_DT_, 'lmi/tmi/slf/slf_DT');

ff_1T_ = connecting(connect(ff_1T), mask_slf_a, mask_slf_b, mask_slf_win); numel(ff_1T_)
ijk2tube(ff_1T_, 'lmi/tmi/slf/slf_1T');

ff_2T_ = connecting(connect(ff_2T), mask_slf_a, mask_slf_b, mask_slf_win); numel(ff_2T_)
ijk2tube(ff_2T_, 'lmi/tmi/slf/slf_2T');

ff_SH_ = connecting(ff_SH, mask_slf_a, mask_slf_b, mask_slf_win); numel(ff_SH_)
ijk2tube(ff_SH_, 'lmi/tmi/slf/slf_SH');


echo off
