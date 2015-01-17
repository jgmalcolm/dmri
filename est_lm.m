function est_fn = est_lm(x0, lb, ub, f_fn, h_fn)
% est_fn - function handle
% x0 - initial state
% lb - lower bound
% ub - upper bound
% f_fn - state correction
% h_fn - state observation
  
  opt = optimset('LargeScale', 'on', ...
                 'Display', 'none', ...
                 'MaxIter', 500, ...
                 'MaxFunEvals', inf, ...
                 'TolFun', 1e-8);
  
  est_fn = @(s) f_fn(lsqnonlin(@(x) s-h_fn(x), ...
                               x0, lb, ub, opt));
end
