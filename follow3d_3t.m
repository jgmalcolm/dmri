function ff = follow3d_3t(S, u, b, mask, X, param)
  % initial state
  [x X P] = deal(X(1:3), X(3 + (1:15)), X(3+15+1:end));
  P = reshape(P, [15 15]);
  fiber = struct('X',   X, ...
                 'm',   X(1:3), ...
                 'fa',  l2fa(X(4:5)), ...
                 'pos', x, ...
                 'P',   P);

  % initialize tracts
  ff = tract_init([x;X]);
  
  % initialize filter
  [f_fn h_fn] = model_3tensor(u, b);
  Q = blkdiag(param.Qm*eye(3), param.Ql*eye(2));
  Q = blkdiag(Q,Q,Q);
  R = blkdiag(param.Rs*eye(size(u,1)));
  est = filter_ukf(f_fn, h_fn, Q, R);

  % main loop
  ct = 0;
  while true
    % estimate
    fiber = step(fiber, S, est, param);

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
      ff = tract_done(ff);
      break
    end
    
    % record every millimeter
    if ct == round(1/param.dt)
      ff = tract_push(ff, [x;X]);
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
    [m1 l1 m2 l2 m3 l3] = state2tensor(X, m);
    % pick most consistent direction
    d1 = m'*m1; d2 = m'*m2; d3 = m'*m3;
    if     d1 >= d2 && d1 >= d3    m = m1; fa = iff(l1(1)<l1(2), 0, l2fa(l1));
    elseif d2 >= d1 && d2 >= d3    m = m2; fa = iff(l2(1)<l2(2), 0, l2fa(l2));
    else                           m = m3; fa = iff(l3(1)<l3(2), 0, l2fa(l3)); end
    
    dx = m ./ v;
  end
end
