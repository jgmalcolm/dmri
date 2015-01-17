function ff = follow_dmfc_2tw(S, u, b, mask, X, param)
  paths;
  
  % initial state
  [x X P] = deal(X(1:3), X(4:15), X(16:end));
  P = reshape(P, [12 12]);
  fiber = struct('X',   X, ...
                 'm',   X(1:3), ...
                 'fa',  l2fa(X(4:5)), 'w', X(6), ...
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
  [f_fn h_fn] = model_2tensorW(u, b);
  Q = blkdiag(param.Qm*eye(3), param.Ql*eye(2), param.Qw);
  Q = blkdiag(Q,Q);
  R = blkdiag(param.Rs*eye(size(u,1)));
  est = filter_cukf(f_fn, h_fn, Q, R, ...
                    param.D, param.d, param.D_, param.d_);

  % main loop
  while true
    % estimate
    fiber = step(fiber, S, est, param);
    
    % unpack
    [X x fa w] = deal(fiber.X, fiber.pos, fiber.fa, fiber.w);

    % terminate if off brain or in CSF
    is_brain = interp3scalar(mask, x, param.voxel) > .01;
    ga = s2ga(h_fn(X));
    is_csf = ga < param.GA_min || fa < param.FA_min || w < param.w_min;
    if ~is_brain || is_csf || ff.cur > 250
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
  [P X m fa w] = deal(p.P, p.X, p.m, p.fa, p.w);
  % move
  [t x] = ode23(@f, [0 1], p.pos);
  % repack
  [p.P p.X p.pos p.m p.fa p.w] = deal(P, X, x(end,:)', m, fa, w);
  
  function dx = f(t, x)
    [X P] = est(X, P, interp3exp(S, x, v));

    % pick most consistent direction
    [m1 l1 w1 m2 l2 w2] = state2tensorW(X, m);
    if (m'*m1) >= (m'*m2),   m = m1; fa = l2fa(l1); w = w1;
    else                     m = m2; fa = l2fa(l2); w = w2; end
    
    m(3) = 0; % HACK
    dx = m ./ v;
  end
end
