function pri = follow2d_1t(S, u, b, param)
  paths;
  
  sz = size(S); sz = sz(1:2);
  
  if param.display
    clf; sp(1,2,1); imagesc(signal2ga(S)); colormap gray; axis image; hold on;
  end
  
%-- loop
  xx(1,:) = 1:.1:4.6;
  xx(2,:) = .4;
%   xx = [3 1]';
  m = [0 1 0];

  %-- cross
%   xx(2,:) = 6.5:.3:14.6;
%   xx(1,:) = 70.4;
%   xx(2,:) = 1:40;
%   xx(1,:) = 39.5;
%   m = [-1 0 0];
%   xx = [70.9 10]';

  % set initial state
  points = struct('pos', num2cell(xx,1), ...
                  'X',   [m 1200 100]');
  
  % two fiber model
  [f_fn h_fn] = model_1tensor(u, b);
  Q = blkdiag(param.Qm*eye(3), param.Ql*eye(2));
  R = blkdiag(param.Rs*eye(size(u,1)));
  est = filter_ukf(f_fn, h_fn, Q, R);
  [points(:).P] = deal(Q);

  % initialize tracts
  pri = cell(size(points));
  [pri{:}] = deal(tract_init);
  for i = 1:numel(pri)
    pri{i} = tract_push(pri{i}, [points(i).pos; points(i).X; Q(:)]);
  end
  
  hist_tr = [];
  hist_det = [];
  hist_fa = [];

  % main loop
  is_valid = true(size(points));
  len = 0;
  while any(is_valid)
    for i = find(is_valid)
      % estimate
      points(i) = step(points(i), S, est, param);

      % unpack
      [X P x] = deal(points(i).X, points(i).P, points(i).pos);

      % record primary
      pri{i} = tract_push(pri{i}, [x; X; P(:)]);

      % terminate if off grid, isotropic, or in CSF
      is_csf = s2ga(h_fn(X)) < param.GA_min;
      if is_offgrid(x, sz)% || is_csf || x(1) < 30 % 15 || len > 100
        is_valid(i) = false;
        pri{i} = tract_done(pri{i});
        if len > 100, warning('wild fiber'); end
      end

      % display
      if param.display
        hist_tr(end+1) = trace(P);
        hist_det(end+1) = det(P(4:5,4:5));
        hist_fa(end+1) = l2fa(X(4:5));

        sp(1,2,1);
        [m1 l1] = state2tensor(X);
        X = [x x] + m1(1:2)*[1 -1]/2;
        plot(X(2,:), X(1,:), 'b');
        sp(3,2,2); plot(hist_tr(20:end));
        sp(3,2,4); plot(hist_det(20:end));
        sp(3,2,6); plot(hist_fa(20:end));
      end
    end
    if param.display, drawnow;
    else fprintf('.'); end
    len = len + 1;
  end
end


function p = step(p, S, est, param)
%   [p.X p.P] = est(p.X, p.P, interp2exp(S, p.pos));
%   p.pos = p.pos + [-1 0]'/5;
%   return

  P = p.P;
  X = p.X;
  
  [t x] = ode23(@f, [0 1], p.pos);
  p.P = P;
  p.X = X;
  p.pos = x(end,:)';
  
  function dx = f(t, x)
    [X P] = est(X, P, interp2exp(S, x));
%     dx = [-1 0]';
    dx = state2tensor(X);
    dx = dx(1:2); % project onto plane
  end
end
