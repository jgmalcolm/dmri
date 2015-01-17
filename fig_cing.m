echo on

%[mask_cing_jm mask_cing] = loadsome('lmi/tensor_TMI/ROIs/ROIs', 'mask_cing_jm', 'mask_cing');
ff_DT = loadsome('lmi/tensor_TMI/DT', 'ff');
ff = exp_cingulum(ff_DT, mask_cing_jm, mask_cing == 1); numel(ff)
ijk2tube(ff, '/tmp/cing_DT');

ff_1T = loadsome('lmi/tensor_TMI/1T', 'ff');
ff = exp_cingulum(ff_1T, mask_cing_jm, mask_cing == 1); numel(ff)
ijk2tube(ff, '/tmp/cing_1T');

ff_2T = loadsome('lmi/tensor_TMI/2T', 'ff');
ff = exp_cingulum(ff_2T, mask_cing_jm, mask_cing == 1); numel(ff)
ijk2tube(ff, '/tmp/cing_2T');

% ff_SH = loadsome('lmi/tensor_TMI/SH', 'ff_sh');
% ff = exp_cingulum(ff_SH, mask_cing_jm, mask_cing == 1); numel(ff)
% ijk2tube(ff, '/tmp/cing_SH');

echo off
