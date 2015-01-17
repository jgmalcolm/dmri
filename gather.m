function [ff1 ff2 param] = gather(base, prefix, ndiv)

  fn = sprintf('%s/%s*-of-%02d.mat', base, prefix, ndiv)
  d = dir(fn);
  %assert((numel(d) == ndiv) || (numel(d) == 6));
  if(numel(d) == ndiv)
  else
    ff1 = []; ff2 = []; param = [];
    return;
  end
  ff1 = {}; ff2 = {};
  for i = 1:numel(d)
    fn = sprintf('%s/%s', base, d(i).name(1:end-4));
    fprintf('%s...  ', fn);

    % grab fibers
     [f param] = loadsome(fn, 'ff', 'param');
     fprintf('%d\n', numel(f));
     if(isempty(f))
      fprintf('unable to load %s\n',fn);
      ff1 = []; ff2 = [];
      return;
    end
    % aggregate
    %ff{i} = f;
    ff1{i} = map(@(x) x(1:13,:), f);
    ff2{i} = map(@(x) x(14:end,:), f);
  end
  ff1 = [ff1{:}];
  ff2 = [ff2{:}];
end
