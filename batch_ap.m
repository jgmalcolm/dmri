function batch_ap(pre, xx, S, p)
  
  paths;
  
  clk = clock;
  id = sprintf('%02d-%02d-%02d%02d%02.0f_%s', clk(2:6), pre)
  %dir = '/home/malcolm/src/lmi/tensor_TMI/ap/';
  dir = '/home/yogesh/yogesh_pi/phd/lmi/clusters';
  clusters = {};

  for i = 1:numel(p)
    idx = apcluster(S, p(i));
    vv = fibers2clusters(xx, idx);
    nc = numel(unique(idx));
    fn = sprintf('%s/%s_%d_%d', dir, id, i, nc);
    ijk2vtk(xx, fn, 'values', vv);
    clusters{end+1} = idx;
    fprintf([fn '...']);
    fn = sprintf('%s/%s', dir, id);
    save(fn, 'p', 'clusters')
    disp('[done]');
  end
  
  fn

end
