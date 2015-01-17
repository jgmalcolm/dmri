function ff = follow_dmfc_1t(S, u, b, mask, X, param)
  paths;
  
  % initial state
  [x X P] = deal(X(1:3), X(4:8), X(9:end));
  P = reshape(P, [5 5]);
  fiber = struct('X',   X, ...
                 'm',   X(1:3), ...
                 'fa',  l2fa(X(4:5)), ...
                 'pos', x, ...
                 'P',   P);
  
  try param.display; catch param.display = false; end
  if param.display
    hold on;
    plot(x(2),x(1),'y.', 'MarkerSize', 20);
  end

  % initialize tracts
  ff = tract_init([x; X]);
  
  % initialize filter
  [f_fn h_fn] = model_1tensor(u, b);
  Q = blkdiag(param.Qm*eye(3), param.Ql*eye(2));
  R = blkdiag(param.Rs*eye(size(u,1)));
  est = filter_ukf(f_fn, h_fn, Q, R);
  
  % main loop
  while true
    % estimate
    fiber = step(fiber, S, est, param);
    
    % unpack
    [X P x fa] = deal(fiber.X, fiber.P, fiber.pos, fiber.fa);

    % terminate if off brain or in CSF
    is_brain = interp3scalar(mask, x, param.voxel) > .05;
    ga = s2ga(h_fn(X));
    is_csf = ga < param.GA_min || fa < param.FA_min;
    if ~is_brain || is_csf || ff.cur > 250
      if ~is_brain, disp('mask mask mask mask mask mask mask mask'), end
      if ga < param.GA_min, disp('ga ga ga ga ga ga ga ga ga ga ga ga'), ga([1 1 1 1]), end
      if fa < param.FA_min, disp('fa fa fa fa fa fa fa fa fa fa fa fa'), fa([1 1 1 1]), end
      if ff.cur > 250, warning('wild fiber'); end
      ff = tract_done(ff);
      break
    end
    ff = tract_push(ff, [x;X]);

    if param.display
      plot(x(2), x(1), 'r.');
      drawnow
    end
  end
end


function p = step(p, S, est, param)
  v = param.voxel';
  % unpack
  [P X m fa] = deal(p.P, p.X, p.m, p.fa);
  % move
  [t x] = ode23(@f, [0 1], p.pos);
  % repack
  [p.P p.X p.pos p.m p.fa] = deal(P, X, x(end,:)', m, fa);
  
  function dx = f(t, x)
    [X P] = est(X, P, interp3exp(S, x, v));
    [m l] = state2tensor(X);
    fa = l2fa(l);
    m(3) = 0; % HACK
    dx = m ./ v;
  end
end
