function [pri sec] = follow3d_3tw(S, u, b, mask, X, is_last, param)
  paths;
  
  % initial state
  [x X P] = deal(X(1:3), X(3 + (1:18)), X(3+18+1:end));
  P = reshape(P, [18 18]);
  fiber = struct('X',   X, ...
                 'm',   X(1:3), ...
                 'fa',  l2fa(X(4:5)), 'w', X(6), ...
                 'pos', x, ...
                 'P',   P);

  % initialize tracts
  [pri sec] = deal(tract_init);
  pri = tract_push(pri, [x; X]);
  
  % initialize filter
  [f_fn h_fn] = model_3tw(u, b);
  Q = blkdiag(param.Qm*eye(3), param.Ql*eye(2), param.Qw);
  Q = blkdiag(Q,Q,Q);
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
    is_brain = interp3scalar(mask, x) > .1;
    is_csf = s2ga(h_fn(X)) < param.GA_min || fa < param.FA_min;
    if ~is_brain || is_csf || pri.cur > 250
      if pri.cur > 250, warning('wild fiber'); end
      if pri.cur < param.len_min
        pri = [];              sec = [];
      else
        pri = tract_done(pri); sec = tract_done(sec);
      end
      break;
    end
    
    pri = tract_push(pri, [x;X]);

    % record branch if necessary
    if ~is_last
      m = fiber.m; P = fiber.P;
      [m1 l1 w1 m2 l2 w2 m3 l3 w3] = state2tw(X, m);
      th1 = m1'*m; th2 = m2'*m; th3 = m3'*m;
      % ignore duplicates
      if m1'*m2>.99                 th2 = inf; end
      if m1'*m3>.99 || m2'*m3>.99   th3 = inf; end

      % determine if branching from current direction
      is_1 = is_component(th1, l1, w1, param);
      is_2 = is_component(th2, l2, w2, param);
      is_3 = is_component(th3, l3, w3, param);

      % record branches
      if is_1
        X = [m1;l1;w1; m2;l2;w2; m3;l3;w3];
        sec = tract_push(sec, [x; X; P(:)]);
      end
      if is_2
        X = [m2;l2;w2; m3;l3;w3; m1;l1;w1];
        P = P([7:18 1:6], [7:18 1:6]);
        sec = tract_push(sec, [x; X; P(:)]);
      end
      if is_3
        X = [m3;l3;w3; m1;l1;w1; m2;l2;w2];
        P = P([13:18 1:12], [13:18 1:12]);
        sec = tract_push(sec, [x; X; P(:)]);
      end
    end
  end
end


function p = step(p, S, est, param)
  % unpack
  [P X m fa w] = deal(p.P, p.X, p.m, p.fa, p.w);
  % move
  [t x] = ode23(@f, [0 param.velocity], p.pos, param.ode);
  % repack
  [p.P p.X p.pos p.m p.fa p.w] = deal(P, X, x(end,:)', m, fa, w);

  function dx = f(t, x)
    [X P] = est(X, P, interp3exp(S, x));

    % pick most consistent direction
    [m1 l1 w1 m2 l2 w2 m3 l3 w3] = state2tw(X, m);
    % pick most consistent direction
    d1 = m'*m1; d2 = m'*m2; d3 = m'*m3;
    if     d1 >= d2 && d1 >= d3    m = m1; fa = l2fa(l1); w = w1;
    elseif d2 >= d1 && d2 >= d3    m = m2; fa = l2fa(l2); w = w2;
    else                           m = m3; fa = l2fa(l3); w = w3; end

    dx = m;
  end
end


function r = is_component(th, l, w, param)
  th_min = param.theta_min; th_max = param.theta_max;
  
  r = th < th_min && th > th_max;
  r = r && l2fa(l) > param.FA_min && l(1) > l(2);
  r = r && w > param.w_min;
end
