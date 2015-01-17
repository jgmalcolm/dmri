function xx = gather_some(base, prefix, ndiv)

  fn = sprintf('%s/%s_*-of-%02d_*_1.mat', base, prefix, ndiv);
  d = dir(fn);
  assert(numel(d) == ndiv);
  
  ff = {};
  for i = 1:numel(d)
    fn = sprintf('%s/%s', base, d(i).name(1:end-6));
    fprintf('%s...', fn);

    % grab whatever points are available
    f = {};
    try
      for i = 1:4
        f{i} = loadsome([fn '_' int2str(i)], 'f');
      end
    catch, end
    f = map(@(x) single(x(1:3,:)), empty([f{:}]));

    fprintf('%d\n', numel(f));
    
    % aggregate
    ff{i} = f;
  end
  ff = [ff{:}];
  xx = [ff{:}];
  xx = unique(xx', 'rows')';
end
