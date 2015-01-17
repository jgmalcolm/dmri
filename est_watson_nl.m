function x  = est_watson_nl(s, u, x0)
% s - input signal
% u - gradients
% x0 - initial state

  opt = optimset('LargeScale', 'on', ...
                 'MaxFunEvals', 25000, ...
                 'Display', 'off', ...
                 'TolFun', 1e-8, ...
                 'MaxIter', 1000);

  if ~exist('x0')
    x0 = [[1 0 0]  1.5  [0 1 0] 1.5]';
  end
  
  x = lsqnonlin(@fn, x0, [], [], opt);
  
  % normalize output
  [m1 k1 m2 k2] = state2watson(x);
  x = [m1' k1 m2' k2]';


  function f = fn(x)
    s_ = model_2watson_h(x, u);
    [m1 k1 m2 k2] = state2watson(x);
    f = [(s - s_); -log(k1)/4; -log(k2)/4];
  end
end
