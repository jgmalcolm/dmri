function ff = follow3d_2t_lm(S, u, b, mask, X, param)
  % initial state
  [x X] = deal(X(1:3), X(4:13));
  fiber = struct('X',   X, ...
                 'm',   X(1:3), ...
                 'fa',  l2fa(X(4:5)), ...
                 'pos', x);

  % initialize tracts
  ff = tract_init([x;X]);
  
  % initialize optimizer
  opt = optimset('LargeScale', 'on', ...
                 'Display', 'none', ...
                 'MaxIter', 500, ...
                 'MaxFunEvals', 1000);
  [f_fn h_fn] = model_2tensor(u, b);
  % inputs: initial state, signal
  est = @(x0,s) f_fn(lsqnonlin(@(x) s-h_fn(x), ...
                               x0, ...
                               param.lm.lb, param.lm.ub, opt));

  % main loop
  ct = 0;
  while true
    % estimate
    fiber = step_euler(fiber, S, est, param);
    
    % unpack
    [X x fa] = deal(fiber.X, fiber.pos, fiber.fa);

    % terminate if off brain or in CSF
    is_brain = interp3scalar(mask, x, param.voxel) > .1;
    ga = s2ga(h_fn(X));
    is_csf = ga < param.GA_min || fa < param.FA_min;
    %is_curving = deflection(ff) < param.min_deflection;

    %find curvature
    curv = FindCurvature(ff.list);
    if(curv ~=0)
      rad_curv = 1/curv;
    else
      rad_curv = 1;
    end
    is_curving = rad_curv < param.min_rad_curv; %we are curving fast...

    if ~is_brain || is_csf || ff.cur > param.max_len || is_curving
      if ff.cur > param.max_len, warning('wild fiber'); end
      ff = tract_done(ff);
      break
    end
    
    % record every third
    if ct == 3
      ff = tract_push(ff, [x;X]);
      ct = 0;
    else
      ct = ct + 1;
    end
  end
end


function p = step_rk(p, S, est, param)
  v = param.voxel';
  % unpack
  [X m fa] = deal(p.X, p.m, p.fa);
  % move
  [t x] = ode23(@f, [0 1], p.pos);
  % repack
  [p.X p.pos p.m p.fa] = deal(X, x(end,:)', m, fa);
  
  function dx = f(t, x)
    X = est(X, interp3exp(S, x, v));

    % pick most consistent direction
    [m1 l1 m2 l2] = state2tensor(X, m);
    if (m'*m1) >= (m'*m2),   m = m1; fa = l2fa(l1);
    else                     m = m2; fa = l2fa(l2); end
    
    dx = m ./ v;
  end
end
function p = step_euler(p, S, est, param)
  v = param.voxel';
  % unpack
  [X m fa] = deal(p.X, p.m, p.fa);
  % move
  p.pos = p.pos + param.dt * f(nan, p.pos);
  % repack
  [p.X p.m p.fa] = deal(X, m, fa);
  
  function dx = f(t, x)
    X = est(X, interp3exp(S, x, v));

    % pick most consistent direction
    [m1 l1 m2 l2] = state2tensor(X, m);
    if (m'*m1) >= (m'*m2),   m = m1; fa = iff(l1(1)<l1(2), 0, l2fa(l1));
    else                     m = m2; fa = iff(l2(1)<l2(2), 0, l2fa(l2)); end
    
    dx = m ./ v;
  end
end
