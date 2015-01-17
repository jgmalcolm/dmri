function x  = est_2tensor_nl(s, u, b, x0)
% s - input signal
% u - gradients
% x0 - initial state
  
  opt = optimset('LargeScale', 'on', ...
                 'MaxFunEvals', 25000, ...
                 'Display', 'off', ...
                 'TolFun', 1e-6, ...
                 'MaxIter', 1000);

  if ~exist('x0')
    x0 = [[1 0 0] 1700 100 ... % aniso
          [0 1 0] 1500 1500]'; % iso
  end
  
  x = lsqnonlin(@fn, x0, [], [], opt);
  % normalize output
  x = model_2tensor_f(x);
  
  function e = fn(x)
    [m1 l1 m2 l2] = state2tensor(x);
    penalty = -log([l1(1)/l1(2); l2(1)/l2(2)])/4;
    e = [s - model_2tensor_h(x, u, b); penalty];
  end
end
