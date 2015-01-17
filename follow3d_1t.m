function ff = follow3d_1t(S, u, b, mask, X, param)
  % initial state
  [x X P] = deal(X(1:3), X(4:8), X(9:end));
  P = reshape(P, [5 5]);
  P = eye(5) / 100;
  fiber = struct('X',   X, ...
                 'fa',  l2fa(X(4:5)), ...
                 'pos', x, ...
                 'P',   P);

  % initialize tracts
  %ff = tract_init([x;X;triu_nz(P)]);
  ff = tract_init(x);
  
  % initialize filter
  [f_fn h_fn] = model_1tensor(u, b);
  Q = blkdiag(param.Qm*eye(3), param.Ql*eye(2));
  R = blkdiag(param.Rs*eye(size(u,1)));
  est = filter_ukf(f_fn, h_fn, Q, R);

  % main loop
  ct = 0;
  while true
    % estimate
    fiber = step_euler(fiber, S, est, param);

    % unpack
    [X P x fa] = deal(fiber.X, fiber.P, fiber.pos, fiber.fa);

    % terminate if off brain or in CSF
    is_brain = interp3scalar(mask, x, param.voxel) > .1;
    ga = inf; %s2ga(h_fn(X));
    is_csf = ga < param.GA_min || fa < param.FA_min;

    %find curvature
    curv = FindCurvature(ff);
    rad_curv = iff(curv, 1/curv, 1);
    is_curving = rad_curv < param.min_radius; %we are curving fast...
    
    if ~is_brain || is_csf || ff.cur > param.max_len || is_curving
      if ff.cur > param.max_len, warning('wild fiber'); end
      ff = tract_done(ff);
      break
    end
    
    % record every millimeter
    if ct == round(1/param.dt)
      %ff = tract_push(ff, [x;X;triu_nz(P)]);
      ff = tract_push(ff, x);
      ct = 0;
    else
      ct = ct + 1;
    end
  end
end


function p = step_rk(p, S, est, param)
  error('do not use')
  v = param.voxel';
  % unpack
  [P X fa] = deal(p.P, p.X, p.fa);
  % move
  [t x] = ode23(@f, [0 1], p.pos);
  % repack
  [p.P p.X p.pos p.fa] = deal(P, X, x(end,:)', fa);
  
  function dx = f(t, x)
    [X P] = est(X, P, interp3exp(S, x, v));
    [m l] = state2tensor(X);
    fa = iff(l(1) > l(2), l2fa(l), 0);
    dx = m ./ v;
  end
end

function p = step_euler(p, S, est, param)
  v = param.voxel';
  % unpack
  [P X fa] = deal(p.P, p.X, p.fa);
  % move
  dx = f(nan, p.pos);
  p.pos = p.pos + param.dt * dx;
  % repack
  [p.P p.X p.fa] = deal(P, X, fa);
  
  function dx = f(t, x)
    [X P] = est(X, P, interp3exp(S, x, v));
    [m l] = state2tensor(X);
    fa = iff(l(1) > l(2), l2fa(l), 0);
    dx = m ./ v;
  end
end
