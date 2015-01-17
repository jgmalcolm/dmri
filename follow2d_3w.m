function pri = follow2d_3w(S, u, param)
  paths;
  
  sz = size(S); sz = sz(1:2);
  
  if param.display
    clf; imagesc(signal2ga(S)); colormap gray; axis image; hold on;
  end
  
%-- cross
  xx(2,:) = 7:.2:14;
  xx(1,:) = 70.4;
%-- X tensor
%   A = 9.25; B = 10.75;
%   xx(2,:) = A:(B-A)/5:B;
%   xx(1,:) = 30.4;

%   xx = [70.4 10]';

  % set initial state
  points = struct('pos', num2cell(xx,1), ...
                  'X',   [[-1 0 0] 1.1 [-1 0 0] .7 [-1 0 0] .7]', ...
                  'm',   [-1 0 0]');
  
  % initialize tracts
  pri = cell(size(points));
  [pri{:}] = deal(tract_init);
  for i = 1:numel(pri)
    pri{i} = tract_push(pri{i}, [points(i).pos; points(i).X]);
  end

  % two fiber model
  [f_fn h_fn] = model_3watson(u);
  est = filter_ukf(f_fn, h_fn, param.Q, param.R);
  [points(:).P] = deal(param.Q);

  % main loop
  is_valid = true(size(points));
  nerr = 0; err = 0;
  len = 0;
  while any(is_valid)
    %fprintf('error %f\n', err);
    nerr = 0; err = 0;
    for i = find(is_valid)
      % estimate
      points(i) = step(points(i), S, est, param);

      % unpack
      x = points(i).pos;
      X = points(i).X;

      %fprintf('%5.2f ', X); fprintf('\n');
      % record primary
      pri{i} = tract_push(pri{i}, [x; X]);

      % terminate if off grid, isotropic, or in CSF
      s = h_fn(X);
      is_csf = std(s) ./ (sqrt(mean(s.^2)) + eps) < param.GA_min;
      if is_offgrid(x, sz) || is_csf || len > 100
        is_valid(i) = false;
        pri{i} = tract_done(pri{i});
        if len > 100, warning('max length'); end
      end

      % display
      if param.display
        [m1 k1 m2 k2 m3 k3] = state2watson(X);
        X = [x x] + m1(1:2)*[1 -1]/2;
        plot(X(2,:), X(1,:), 'r');
        X = [x x] + m2(1:2)*[1 -1]/2;
        plot(X(2,:), X(1,:), 'b');
        X = [x x] + m3(1:2)*[1 -1]/2;
        plot(X(2,:), X(1,:), 'm');
      end
      z = interp2exp(S, x); z = z / norm(z);
      e = (norm(z-s)/norm(z))^2;
      err = (nerr*err + e)/(nerr+1);
      nerr = nerr + 1;
    end
    if param.display, drawnow; end
    fprintf('.');
    len = len + 1;
  end
  fprintf('\n');
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
    s = interp2exp(S, x);
    [X P] = est(X, P, s/norm(s));
    
    m = [-1 0 0]';  % HACK to favor straight up
    [m1 k1 m2 k2 m3 k3] = state2watson(X, m);
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
