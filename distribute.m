function distribute(ff, ff_, param, pre, post, ndiv)
  n = numel(ff);
  param.ndiv = ndiv;
  ii = 1:floor(n / ndiv);
  for i = 1:ndiv-1
    f  = ff(ii);
    f_ = ff_(ii);
    fn = sprintf('%s_%02d-of-%02d_%s', pre, i, ndiv, post);
    disp(fn);
    system(['touch ' fn(1:end-1) '1.mat']);
    save(fn, 'f', 'f_', 'param');
    ii = ii + floor(n / ndiv);
  end
  
  % last one gets whatever is left
  ii = ii(1):numel(ff);
  f  = ff(ii);
  f_ = ff_(ii);
  fn = sprintf('%s_%02d-of-%02d_%s', pre, ndiv, ndiv, post);
  disp(fn);
  system(['touch ' fn(1:end-1) '1.mat']);
  save(fn, 'f', 'f_', 'param');
  
end
