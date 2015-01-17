function mat2tube(dir)
  paths
  for i = 1:3
    fn = sprintf('%s/f_%d.mat',dir,i);
    if ~exist(fn), break, end
    ff = loadsome(fn, 'f');
    ijk2tube(fiber2ijk(ff), sprintf('%s/%s_%d', dir, dir, i));
  end
end
