function [ff ff_] = follow_lm_c(S, u, b, mask, X, param, is_last)
  X = double(X);
  % initial state
  [x X] = deal(X(1:3), X(4:13));
  fiber = struct('X',   X, ...
                 'm',   X(1:3), ...
                 'fa',  l2fa(X(4:5)), ...
                 'pos', x);

  % initialize tracts
  ff  = tract_init([x;X]);
  ff_ = tract_init;

  % setup single-tensor estimation
  est_dt = nan;%est_dt_fn(u, b);
  
  % setup LM estimation
  opt = optimset('LargeScale', 'on',  'Display',     'none', ...
                 'MaxIter',    500,   'MaxFunEvals', 1000);
  [f_fn h_fn] = model_2tensor(u, b);
  est_lm = @(x0,s) f_fn(lsqnonlin(@(x) s-h_fn(x), ...
                                  x0, ...
                                  param.lm.lb, param.lm.ub, opt));

  % main loop
  ct = 0;
  while true
    % estimate
    fiber = step(fiber, S, est_dt, est_lm, param);
    
    % unpack
    [X x fa] = deal(fiber.X, fiber.pos, fiber.fa);

    % terminate if off brain or in CSF
    is_brain = interp3scalar(mask, x, param.voxel) > .1;
    ga = s2ga(h_fn(X));
    is_csf = ga < param.GA_min || fa < param.FA_min;

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
      ff  = tract_done(ff);
      ff_ = tract_done(ff_);
      return
    end
    
    % record every millimeter
    if ct < round(1/param.dt)
      ct = ct + 1;
      continue
    end

    assert(ct == round(1/param.dt))
    ct = 0;

    ff = tract_push(ff, [x;X]);
    
    % record branch if necessary
    if ~is_last
      m = fiber.m;
      [m1 l1 m2 l2] = state2tensor(X, m);
      is_two = l1(1) > l1(2) && l2(1) > l2(2); % non-planar
      fa = param.FA_min;
      is_two = is_two && l2fa(l1) > fa && l2fa(l2) > fa;
      th = m1'*m2;
      is_branching = th < param.theta_min && th > param.theta_max;
      if is_two && is_branching
        if m'*m1 > m'*m2
          X = [m2;l2; m1;l1];
        else
          X = [m1;l1; m2;l2];
        end
        ff_ = tract_push(ff_, [x;X]);
      end
    end

  end
end


function p = step(p, S, est_dt, est_lm, param)
  v = param.voxel';
  % unpack
  [X m fa] = deal(p.X, p.m, p.fa);
  % move
  p.pos = p.pos + param.dt * df(p.pos);
  % repack
  [p.X p.m p.fa] = deal(X, m, fa);
  
  function dx = df(x)
    s = interp3exp(S, x, v);
    %X = est_dt(s);
    X = est_lm(X, s);

    % pick most consistent direction
    [m1 l1 m2 l2] = state2tensor(X, m);
    if (m'*m1) >= (m'*m2),   m = m1; fa = iff(l1(1)<l1(2), 0, l2fa(l1));
    else                     m = m2; fa = iff(l2(1)<l2(2), 0, l2fa(l2)); end
    
    dx = m ./ v;
  end
end

function fn = est_dt_fn(u, b)
  fn = @est;

  ux = u(:,1); uy = u(:,2); uz = u(:,3);
  B = -b * [ux.^2  2*ux.*uy  2*ux.*uz  uy.^2  2*uy.*uz  uz.^2];
  
  function X = est(s)
    D = real(B \ log(s)); % ensure real since unconstrained
    [U V] = svd(D([1 2 3; 2 4 5; 3 5 6]));
    m = U(:,1);
    l = [V(1); (V(5)+V(9))/2]*1e6;
    X = [m;l;m;l];
  end
end
