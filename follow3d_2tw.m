function ff = follow3d_2tw(S, u, b, mask, X, param)

  % initial state
  [x X P] = deal(X(1:3), X(4:14), X(15:end));
  P = reshape(P, [11 11]);
  fiber = struct('X',   X, ...
                 'm',   X(1:3), ...
                 'fa',  l2fa(X(4:5)), ...
                 'pos', x, ...
                 'P',   P);

  % initialize tracts
  ff = tract_init([x;X]);
  
  % initialize filter
  [f_fn h_fn] = model_2tensorW(u, b);
  Q = blkdiag(param.Qm*eye(3), param.Ql*eye(2), param.Qw);
  Q = blkdiag(Q,param.Qm*eye(3), param.Ql*eye(2));
  R = blkdiag(param.Rs*eye(size(u,1)));
  est = filter_cukf(f_fn, h_fn, Q, R, param.D, param.d);
  
  % main loop
  while true
    % estimate
    fiber = step(fiber, S, est, param);

    % unpack
    [X x fa] = deal(fiber.X, fiber.pos, fiber.fa);

    % terminate if off brain or in CSF
    is_brain = interp3scalar(mask, x, param.voxel) > .1;
    ga = s2ga(h_fn(X));
    is_csf = ga < param.GA_min || fa < param.FA_min;
    if ~is_brain || is_csf || ff.cur > 250
      if ff.cur > 250, warning('wild fiber'); end
      ff = tract_done(ff);
      break
    end

    ff = tract_push(ff, [x;X]);
  end
end


function p = step(p, S, est, param)
  v = param.voxel;
  % unpack
  [P X m] = deal(p.P, p.X, p.m);
  % move
  [t x] = ode23(@f, [0 1], p.pos);
  % repack
  fa = l2fa(X(4:5));
  [p.P p.X p.pos p.m p.fa] = deal(P, X, x(end,:)', m, fa);
  
  function dx = f(t, x)
    [X P] = est(X, P, interp3exp(S, x, v));
    m = state2tensorW(X, m);
    dx = m ./ v';
  end
end
