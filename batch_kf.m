function batch_kf(param)
  tic
  for b = 1000
    fn = sprintf('matlab_3cross_w_b%d', b)
    [tract u] = loadsome(fn, 'tract', 'u');
    
    ff = cell(size(tract));
    n = numel(tract);
    for i = 1:n
      T = tract(i);
      fprintf('KF-%s [%3.0f%%] b=%d   th %d   sigma %.1f  w %.1f  ', ...
              param.str, 100*i/n, b, T.th, T.sigma, T.w);
      ff{i} = param.follow(T.S, u, b, param);
      fprintf('\n');
    end
    fn = sprintf('%s_%s_KF', fn, param.str)
    ff = map(@(ff) map(@double, ff), ff);
    save(fn, 'ff', 'param');
  end
  toc
end
