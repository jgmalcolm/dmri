function [pri sec] = follow3d_3w(S, u, mask, pri_, param)
  paths;

  % initial state
  n = sum(cellfun(@(s) size(s,2), pri_));
  fprintf('preparing %d fibers\n', n);
  points(n).X = []; % preallocate
  j = 1;
  for i = 1:numel(pri_)
    for X = pri_{i}
      [x X P] = deal(X(1:3), X(4:15), X(16:end));
      P = reshape(P, [12 12]);
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
  [f_fn h_fn] = model_3watson(u);
  Q = blkdiag(param.Qm*eye(3),param.Qk);
  Q = blkdiag(Q,Q,Q);
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
      x = points(i).pos;
      m = points(i).m;
      P = points(i).P;
      X = points(i).X;
      [m1 k1 m2 k2 m3 k3] = state2watson(X, m);
      th1 = m1'*m;
      th2 = m2'*m; 
      th3 = m3'*m;
      % ignore duplicates
      if m1'*m2>.99                 th2 = inf; end
      if m1'*m3>.99 || m2'*m3>.99   th3 = inf; end
      
      % record primary
      pri{i} = tract_push(pri{i}, [x;X]);

      % determine if branching from current direction
      k = param.k_min; th_min = param.theta_min; th_max = param.theta_max;
      is_branch_1 = th1 < th_min && th1 > th_max && k1 > k;
      is_branch_2 = th2 < th_min && th2 > th_max && k2 > k;
      is_branch_3 = th3 < th_min && th3 > th_max && k3 > k;

      % record branches
      if is_branch_1
        X = [m1;k1; m2;k2; m3;k3];
        sec{i} = tract_push(sec{i}, [x; X; P(:)]);
      end
      if is_branch_2
        X = [m2;k2; m3;k3; m1;k1];
        P = P([5:12 1:4], [5:12 1:4]);
        sec{i} = tract_push(sec{i}, [x; X; P(:)]);
      end
      if is_branch_3
        X = [m3;k3; m1;k1; m2;k2];
        P = P([9:12 1:8], [9:12 1:8]);
        sec{i} = tract_push(sec{i}, [x; X; P(:)]);
      end

      % terminate if off brain or in CSF
      z = interp3exp(S,x); z = z / norm(z);
      s = model_3watson_h(X, u);
      e = (norm(z-s)/norm(z))^2;
      is_brain = interp3scalar(mask, x) > .1;
      is_csf = std(s) ./ (sqrt(mean(s.^2)) + eps) < param.GA_min;
      if ~is_brain || is_csf
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

    [m1 k1 m2 k2 m3 k3] = state2watson(X, m);
    % pick most consistent direction
    d1 = m' * m1; d2 = m' * m2; d3 = m' * m3;
    if     d1 >= d2 && d1 >= d3    m = m1;
    elseif d2 >= d1 && d2 >= d3    m = m2;
    else                           m = m3; end
    
    dx = m;
  end
end
