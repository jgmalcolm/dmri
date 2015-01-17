function ff = follow2d_2t(S, u, b, param)
  paths;
  
  sz = size(S); sz = sz(1:2);
  
  if param.display
    clf; imagesc(signal2ga(S)); colormap gray; axis image; hold on;
  end
  
%-- loop
  xx(1,:) = 1:.1:4.6;
  xx(2,:) = .4;
%   xx = [3 1]';
  m = [0 1 0];

%-- cross
%   xx(2,:) = 7:.6:14;
%   xx(1,:) = 70.4;
%   m = [-1 0 0];
%   xx = [70.4 10]';

%-- X
%   A = 9.25; B = 10.75;
%   xx(2,:) = A:(B-A)/5:B;
%   xx(1,:) = 70.4;

  % set initial state
  points = struct('pos', num2cell(xx,1), ...
                  'X',   [m 1200 100 m 1200 100]', ...
                  'm',   m');
  
  % initialize tracts
  ff = cell(size(points));
  for i = 1:numel(ff)
    ff{i} = tract_init([points(i).pos; points(i).X]);
  end

  % two fiber model
  [f_fn h_fn] = model_2tensor(u, b);
  Q = blkdiag(param.Qm*eye(3), param.Ql*eye(2));
  Q = blkdiag(Q,Q);
  R = blkdiag(param.Rs*eye(length(u)));
  est = filter_ukf(f_fn, h_fn, Q, R);
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
      ff{i} = tract_push(ff{i}, [x;X]);

      % terminate if off grid, isotropic, or in CSF
      is_csf = s2ga(h_fn(X)) < param.GA_min;
      if is_offgrid(x, sz) || is_csf || len > 100
        is_valid(i) = false;
        ff{i} = tract_done(ff{i});
        if len > 100, warning('wild fiber'); end
      end

      % display
      if param.display
        [m1 l1 m2 l2] = state2tensor(X);
        X = [x x] + m1(1:2)*[1 -1]/2;
        plot(X(2,:), X(1,:), 'b');
        %X = [x x] + m2(1:2)*[1 -1]/2;
        plot(x(2) + m2(2)*[1 -1]/2, ...
             x(1) + m2(1)*[1 -1]/2, 'r');
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
  
  [t x] = ode23(@f, [0 1], p.pos);
  
  p.P = P;
  p.X = X;
  p.m = m;
  p.pos = x(end,:)';
  
  function dx = f(t, x)
    [X P] = est(X, P, interp2exp(S, x));
    
    %m = [-1 0 0]';  % HACK to favor straight up
    [m1 l1 m2 l2] = state2tensor(X, m);
    % pick most similar direction
    if m'*m1 >= m'*m2   m = m1;
    else                m = m2; end

    dx = m(1:2); % project onto plane
  end
end
