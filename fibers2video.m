function fibers2video(ff, id)
  paths
  err = mkdir([tempdir id]);
  
  n_max = max(cellfun(@(f) size(f,2), ff));
  
  for i = 3:n_max
    ff_ = map(@(f) f(:,1:min(i,end)), ff);
    ff_ = {ff_{cellfun(@(f) size(f,2) > 1,ff_)}}; % at least two points
    fn = sprintf('%s%s/%06d', tempdir, id, i);
    fprintf('%s  (of %d)\n', fn, n_max);
    ijk2vtk(fiber2ijk(ff_), fn);
  end
end
