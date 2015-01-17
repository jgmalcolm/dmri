echo on
% paths
% mask_ifo = nrrdLoad('lmi/tmi/ioff/01045_ioff.nrrd');
% load lmi/tmi/ROIs/ROIs
mA = (mask_ifo == 4);
mB = (mask_ifo == 5);
mC = (mask_ifo == 7);
mD_= (mask_cing == 1);  % midline
fn = 'lmi/tmi/ioff/ifo_SH'

ff_ = connecting(ff2, mA, mB, mC, mD_); 
numel(ff_)
ff_ = ff_(subsample(4e3, numel(ff_)));
ijk2tube(ff_, fn);
echo off
return

ff = connecting(connect(ff_DT), mA, mB, mC, mD_); numel(ff)
ff = ff(subsample(4e3, numel(ff)));
ijk2tube(ff, 'lmi/tmi/ioff/ifo_DT');

ff = connecting(connect(ff_1T), mA, mB, mC, mD_); numel(ff)
ff = ff(subsample(4e3, numel(ff)));
ijk2tube(ff, 'lmi/tmi/ioff/ifo_1T');

ff = connecting(connect(ff_2T), mA, mB, mC, mD_); numel(ff)
ff = ff(subsample(4e3, numel(ff)));
ijk2tube(ff, 'lmi/tmi/ioff/ifo_2T');

ff = connecting(ff_SH, mA, mB, mC, mD_); numel(ff)
ff = ff(subsample(4e3, numel(ff)));
ijk2tube(ff, 'lmi/tmi/ioff/ifo_SH');

echo off
