function ff = follow3d_2t(S, u, b, mask, X, param)
  % initial state
  [x X P] = deal(X(1:3), X(4:13), X(14:end));
  P = reshape(P, [10 10]);
  fiber = struct('X',   X, ...
                 'm',   X(1:3), ...
                 'fa',  l2fa(X(4:5)), ...
                 'pos', x, ...
                 'P',   P);

  % initialize tracts
  if param.save_cov
    ff = tract_init([x;X;triu_nz(P)]);
  else
    ff = tract_init([x;X]);
  end
  
  % initialize filter
  [f_fn h_fn] = model_2tensor(u, b);
  Q = blkdiag(param.Qm*eye(3), param.Ql*eye(2));
  Q = blkdiag(Q,Q);
  R = blkdiag(param.Rs*eye(size(u,1)));
  est = filter_ukf(f_fn, h_fn, Q, R);

  % main loop
  ct = 0;
  while true
    % estimate
    fiber = step(fiber, S, est, param);
    
    % unpack
    [X x fa P] = deal(fiber.X, fiber.pos, fiber.fa, fiber.P);

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
      ff = tract_done(ff);
      break
    end
    
    % record every millimeter
    if ct == round(1/param.dt)
      if param.save_cov 
        ff = tract_push(ff, [x;X;triu_nz(P)]);
      else
        ff = tract_push(ff, [x;X]);
      end
      ct = 0;
    else
      ct = ct + 1;
    end
  end
end


function p = step(p, S, est, param)
  v = param.voxel';
  % unpack
  [P X m fa] = deal(p.P, p.X, p.m, p.fa);
  % move
  p.pos = p.pos + param.dt * f(p.pos);
  % repack
  [p.P p.X p.m p.fa] = deal(P, X, m, fa);
  
  function dx = f(x)
    [X P] = est(X, P, interp3exp(S, x, v));

    % pick most consistent direction
    [m1 l1 m2 l2] = state2tensor(X, m);
    if (m'*m1) >= (m'*m2),   m = m1; fa = iff(l1(1)<l1(2), 0, l2fa(l1));
    else                     m = m2; fa = iff(l2(1)<l2(2), 0, l2fa(l2)); end
    
    dx = m ./ v;
  end
end
