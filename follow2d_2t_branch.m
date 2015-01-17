function [pri sec] = follow2d_2t_branch(S, u, b, param)
  paths;
  
  sz = size(S); sz = sz(1:2);
  
  xx = [30 10]';
  
  % estimate and orient initial state
  points = struct('pos', xx, ...
                  'X',   [[-1 0 0] 1200 100 [-1 0 0] 1200 100]', ...
                  'm',   [-1 0 0]');
  
  if param.display
    cla; imagesc(signal2ga(S)); colormap gray; axis image; hold on;
  end
  
  % initialize tracts
  [pri sec_] = deal(tract_init);
  pri = tract_push(pri, [points.pos; points.X]);
  
  % initialize filter
  up = [-1 0 0]';
  [f_fn h_fn] = model_2tensor(u, b);
  est = filter_ukf(f_fn, h_fn, param.Q, param.R);
  [points(:).P] = deal(param.Q);

  % main loop
  is_valid = true;
  while is_valid
    % estimate
    points = step(points, S, est, param, up);

    % unpack
    x = points.pos;
    X = points.X;
    [m1 l1 m2 l2] = state2tensor(X);
    th = abs(m1'*m2);

    % record primary
    pri = tract_push(pri, [x;X]);

    % record branch if necessary
    is_two = l2fa(l1) > param.FA_min && l2fa(l2) > param.FA_min;
    is_branching = th < param.theta_min && th > param.theta_max;
    if is_two && is_branching
      if param.display, plot(x(2),x(1),'go'); end
      m = points.m;
      if m1'*m < 0,   m1 = -m1; end % reorient if necessary
      if m2'*m < 0,   m2 = -m2; end
      d1 = abs(m'*m1);          d2 = abs(m'*m2);
      if d1 > d2
        X = [m2;l2; m1;l1];
        P = fftshift(points.P); % HACK: swap covariance entries
      else
        X=  [m1;l1; m2;l2];
        P = points.P;
      end
      sec_ = tract_push(sec_, [x; X; P(:)]);
    end

    % terminate if off grid, isotropic, or in CSF
    s = model_2tensor_h(X, u, b);
    is_csf = std(s) ./ (sqrt(mean(s.^2)) + eps) < param.GA_min;
    if is_offgrid(x, sz) || is_csf
      is_valid = false;
      pri = tract_done(pri);
      sec_= tract_done(sec_);
    end
    
    % display
    if param.display
      if l2fa(l1) > param.FA_min
        X = [x x] + m1(1:2)*[1 -1]/2;
        plot(X(2,:), X(1,:), 'b');
      end
      if l2fa(l2) > param.FA_min
        X = [x x] + m2(1:2)*[1 -1]/2;
        plot(X(2,:), X(1,:), 'r');
      end
      drawnow
    end
    fprintf('.');
  end
  pri = {pri};
  
  %--- secondaries
  points = [];
  for s = sec_
    [x X P] = deal(s(1:2), s(3:12), s(13:end));
    points(end+1).pos = x;
    points(end  ).X   = X;
    points(end  ).m   = unpack_tensor(X);
    points(end  ).P   = reshape(P, [10 10]);
  end

  % initialize tracts
  sec = cell(size(points));
  [sec{:}] = deal(tract_init);
  for i = 1:numel(sec)
    sec{i} = tract_push(sec{i}, [points(i).pos;points(i).X]);
  end

  % initialize filter
  [f_fn h_fn] = model_2tensor(u, b);
  est = filter_ukf(f_fn, h_fn, param.Q, param.R);
  [points(:).P] = deal(param.Q);

  % main loop
  is_valid = true(size(points));
  while any(is_valid)
    i = find(is_valid);
    for i = i
      % estimate
      points(i) = step(points(i), S, est, param);

      % unpack
      x = points(i).pos;
      X = points(i).X;
      [m1 l1 m2 l2] = state2tensor(X);

      % record
      sec{i} = tract_push(sec{i}, [x;X]);

      % terminate if off grid or in CSF
      s = model_2tensor_h(X, u, b);
      is_csf = std(s) ./ (sqrt(mean(s.^2)) + eps) < param.GA_min;
      if is_offgrid(x, sz) || is_csf
        is_valid(i) = false;
        sec{i} = tract_done(sec{i});
      end

      % display
      if param.display
        if l2fa(l1) > param.FA_min
          X = [x x] + m1(1:2)*[1 -1]/2;
          plot(X(2,:), X(1,:), 'b');
        end
        if l2fa(l2) > param.FA_min
          X = [x x] + m2(1:2)*[1 -1]/2;
          plot(X(2,:), X(1,:), 'r');
        end
        drawnow
      end
    end
    fprintf('+');
  end
  fprintf('\n');
end


function p = step(p, S, est, param, m_bias)
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
    
    [m1 l2 m2 l2] = state2tensor(X);
    % ensure same general direction
    if exist('m_bias'), m = m_bias; end % HACK
    m1 = m1 * sign(m1'*m);
    m2 = m2 * sign(m2'*m);
    % pick most similar direction
    d1 = m' * m1;
    d2 = m' * m2;
    if d1 >= d2  m = m1;
    else         m = m2; end
    
    dx = m(1:2);
  end
end
