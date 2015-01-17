function [ff param] = gather(base, prefix, ndiv)

  fn = sprintf('%s/%s*-of-%d.mat', base, prefix, ndiv);
  d = dir(fn);
  assert(numel(d) == ndiv);

  ff = {};
  for i = 1:numel(d)
    fn = sprintf('%s/%s', base, d(i).name(1:end-4));
    fprintf('%s...  ', fn);

    % grab fibers
    [f param] = loadsome(fn, 'ff', 'param');
    fprintf('%d\n', numel(f));
    
    % aggregate
    ff{i} = f;
  end
  ff = [ff{:}];
end
