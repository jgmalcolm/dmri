function m = nhdr2mat(fn, ty, sz)
% NHDR2MAT Read nhdr files
%
% M = NHDR2MAT('/projects/schiz/3Tdata/case01009/diff/01009-dwi-filt-Ed.raw.gz', 'int16', [144 144 85 59])
% M = NHDR2MAT('/projects/schiz/3Tdata/case01009/projects/20071213-usman-coreg/case01009_trace_tst.raw', 'single', [144 144 85])
% M = NHDR2MAT('/projects/schiz/3Tdata/case01009/projects/20071213-usman-coreg/1_transform_tst/xformed_case01009_ICBM_WMPM.raw.gz', 'uint8', [144 144 85])

  % compressed?
  if fn(end) == 'z'
    fn_ = tempname;
    system(['cp ' fn ' ' fn_ '.gz']);
    system(['gunzip ' fn_ '.gz']);
    fn = fn_;
  end
  fid = fopen(fn, 'r');
  m = cast(fread(fid, inf, ty), ty);
  fclose(fid);
  if numel(m) ~= prod(sz)
    [numel(m) prod(sz)]
    error('ensure proper type: int16, uint8, ...');
  end
  m = reshape(m, sz);
end
