function [pri sec] = follow3d_2w(S, u, mask, pri_, param)
  paths;
  
  % initial state
  n = sum(cellfun(@(s) size(s,2), pri_));
  fprintf('preparing %d fibers\n', n);
  points(n).X = []; % preallocate
  j = 1;
  for i = 1:numel(pri_)
    for X = pri_{i}
      [x X P] = deal(X(1:3), X(4:11), X(12:end));
      P = reshape(P, [8 8]);
      points(j).X   = X;
      points(j).m   = X(1:3);
      points(j).pos = x;
      points(j).P   = P;
      
      j = j + 1;
    end
  end
  clear pri_

  % initialize tracts
  [pri sec] = deal(cell(size(points)));
  [pri{:} sec{:}] = deal(tract_init);
  for i = 1:numel(pri)
    pri{i} = tract_push(pri{i}, [points(i).pos; points(i).X]);
  end
  
  % initialize filter
  [f_fn h_fn] = model_2watson(u);
  Q = blkdiag(param.Qm*eye(3),param.Qk);
  Q = blkdiag(Q,Q);
  R = blkdiag(param.Rs*eye(102));
  est = filter_ukf(f_fn, h_fn, Q, R);

  % main loop
  is_valid = true(size(points));
  err = 0; nerr = 0;
  while any(is_valid)
    i = find(is_valid);
    fprintf('tracking %d fibers (error %f)\n', numel(i), err);
    nerr = 0; err = 0;
    for i = i
      % estimate
      points(i) = step(points(i), S, est, param);

      % unpack
      X = points(i).X;
      x = points(i).pos;
      m = points(i).m;
      [m1 k1 m2 k2] = state2watson(X, m);
      th = abs(m1'*m2);
      P = points(i).P;

      % record primary
      pri{i} = tract_push(pri{i}, [x;X]);

      % record branch if necessary
      is_two = k1 > param.k_min && k2 > param.k_min;
      is_branching = th < param.theta_min && th > param.theta_max;
      if is_two && is_branching
        if m'*m1 > m'*m2
          X = [m2;k2; m1;k1];
          P = P([5:8 1:4],[5:8 1:4]);
        else
          X=  [m1;k1; m2;k2];
        end
        sec{i} = tract_push(sec{i}, [x; X; P(:)]);
      end

      % terminate if off brain or in CSF
      z = interp3exp(S,x); z = z / norm(z);
      s = model_2watson_h(X, u);
      e = (norm(z-s)/norm(z))^2;
      is_brain = interp3scalar(mask, x) > .1;
      is_csf = std(s) ./ (sqrt(mean(s.^2)) + eps) < param.GA_min;
      if ~is_brain || is_csf || e > 0.1
        is_valid(i) = false;
        pri{i} = tract_done(pri{i});
        sec{i} = tract_done(sec{i});
      end
      err = (nerr*err + e)/(nerr+1);
      nerr = nerr + 1;
    end
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
    s = interp3exp(S, x);
    [X P] = est(X, P, s/norm(s));

    [m1 k1 m2 k2] = state2watson(X, m);
    % pick most consistent direction
    if (m'*m1) >= (m'*m2),   m = m1;
    else                     m = m2; end
    
    dx = m;
  end
end
