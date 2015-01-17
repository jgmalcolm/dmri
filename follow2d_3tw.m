function pri = follow2d_3tw(S, u, b, param)
  paths;
  
  sz = size(S); sz = sz(1:2);
  
  if param.display
    clf; imagesc(signal2ga(S)); colormap gray; axis image; hold on;
  end
  
  xx(2,:) = 7:.6:14;
  xx(1,:) = 70.4;

  %xx = [70.4 10]';

  % set initial state
  X = [[-1 0 0] [1200 100] 1/3];
  points = struct('pos', num2cell(xx,1), ...
                  'X',   [X X X]', ...
                  'm',   [-1 0 0]');
  
  % initialize tracts
  pri = cell(size(points));
  [pri{:}] = deal(tract_init);
  for i = 1:numel(pri)
    pri{i} = tract_push(pri{i}, [points(i).pos; points(i).X]);
  end

  % three fiber model
  [f_fn h_fn] = model_3tw(u, b);
  Q = blkdiag(param.Qm*eye(3), param.Ql*eye(2), param.Qw);
  Q = blkdiag(Q,Q,Q);
  R = blkdiag(param.Rs*eye(size(u,1)));
  est = filter_cukf(f_fn, h_fn, Q, R, ...
                    param.D, param.d, param.D_, param.d_);
  [points(:).P] = deal(Q);

  % main loop
  is_valid = true(size(points));
  len = 0;
  while any(is_valid)
    for i = find(is_valid)
      % estimate
      points(i) = step(points(i), S, est, param);

      % unpack
      x = points(i).pos;
      X = points(i).X;

      % record primary
      pri{i} = tract_push(pri{i}, [x; X]);

      % terminate if off grid, isotropic, or in CSF
      is_csf = s2ga(h_fn(X)) < param.GA_min;
      if is_offgrid(x, sz) || is_csf || x(1) < 10 || len > 100
        is_valid(i) = false;
        pri{i} = tract_done(pri{i});
        if len > 100, warning('max length'); end
      end

%       z = interp2exp(S, x);
%       fprintf('  error %f\n', (norm(z-h_fn(X))/norm(z))^2);

      % display
      if param.display
        [m1 l1 w1 m2 l2 w2 m3 l3 w3] = state2tw(X);
        X = [x x] + m1(1:2)*[1 -1]/2;
        if w1 > param.w_min, plot(X(2,:), X(1,:), 'r'), end
        X = [x x] + m2(1:2)*[1 -1]/2;
        if w2 > param.w_min, plot(X(2,:), X(1,:), 'b'), end
        X = [x x] + m3(1:2)*[1 -1]/2;
        if w3 > param.w_min, plot(X(2,:), X(1,:), 'g'), end
      end
    end
    if param.display, drawnow;
    else fprintf('.'); end
    len = len + 1;
  end
end


function p = step(p, S, est, param)
  P = p.P;
  X = p.X;
  m = p.m;
  
  [t x] = ode23(@f, [0 param.velocity], p.pos);
  p.P = P;
  p.X = X;
  p.pos = x(end,:)';
  p.m = m;
  
  function dx = f(t, x)
    [X P] = est(X, P, interp2exp(S, x));
    
    m = [-1 0 0]';  % HACK to favor straight up
    [m1 l1 w1 m2 l2 w2 m3 l3 w3] = state2tw(X, m);
    % pick most consistent direction
    d1 = m' * m1;
    d2 = m' * m2;
    d3 = m' * m3;
    if     d1 >= d2 && d1 >= d3    m = m1;
    elseif d2 >= d1 && d2 >= d3    m = m2;
    else                           m = m3; end

    dx = m(1:2); % project onto plane
  end
end
