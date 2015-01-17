function batch_lm(param)
  tic
  for b = 1000
    fn = sprintf('matlab_3cross_w_b%d', b)
    [tract u] = loadsome(fn, 'tract', 'u');
    
    [f_fn h_fn] = model_2tensor(u, b);

    ff = cell(size(tract));
    n = numel(tract);
    for i = 1:n
      T = tract(i);
      fprintf('LM-%s [%3.0f%%] b=%d   th %d   sigma %.1f  w %.1f  ', ...
              param.str, 100*i/n, b, T.th, T.sigma, T.w);
      
      % set initial state to be perfect
      th = pi * T.th / 180;
      x0 = [[-1 0 0]             T.lambda(1:2) ...
            [-cos(th) sin(th) 0] T.lambda(1:2)];
      x_ = [-cos(th) cos(th)*(1-cos(th))/sin(th)];
      x_(3) = sqrt(1 - norm(x_)^2);
      x0 = [x0 x_ T.lambda(1:2)]';
      est = est_lm(x0, param.lm.lb, param.lm.ub, f_fn, h_fn);
      % grab region of crossing
      ff{i} = fiber_lm(T.S, T.is_cross, est, param);
      fprintf('\n');
    end
    fn = sprintf('%s_%s_LM', fn, param.str)
    save(fn, 'ff', 'param');
  end
  toc
end
