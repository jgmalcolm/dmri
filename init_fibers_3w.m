function pri = init_fibers_3w(S, seeds, u, proj, param)
  paths;
  
  % erode to find enclosed space
  %seeds = erode(seeds);

  fprintf('initial seed voxels: %d\n', nnz(seeds));

  %E = [[0 0 0]'];
  E = [[0 0 0]' eye(3) -eye(3)]/3;
  Q = blkdiag(param.Qm*eye(3),param.Qk);
  Q = flat(blkdiag(Q,Q,Q));

  % estimate initial state
  [x(1,:) x(2,:) x(3,:)] = ind2sub(size(seeds), find(seeds));
  n = nnz(seeds) * size(E,2) * 4;
  pri = cell(1,n);
  fprintf('initial seed upper limit: %d\n', n);
  per = 1;
  i = 1;
  for x = x
    for e = E
      s = interp3exp(S, x+e); s = s / norm(s);
      X = proj(s);
      [m1 k1 m2 k2 m3 k3] = state2watson(X);
      if m1'*m2 < 0, m2 = -m2; end % same general direction as m1
      if m1'*m3 < 0, m3 = -m3; end % same general direction as m1
      if k1 >= param.k_min
        pri{i  } = [x+e;  m1; k1;  m2; k2; m3; k3; Q];
        pri{i+1} = [x+e; -m1; k1; -m2; k2; m3; k3; Q];
        i = i + 2;
      end
      th = m1'*m2;  assert(th >= 0);
      if k2 >= param.k_min && th < param.theta_max
        pri{i  } = [x+e;  m2; k2;  m1; k1; m3; k3; Q];
        pri{i+1} = [x+e; -m2; k2; -m1; k1; m3; k3; Q];
        i = i + 2;
      end
      if 100*i/n >= per
        fprintf('  %d of %d  [%.0f%%]\n', i, n, i / n * 100);
        per = round(100*i/n) + 1;
      end
    end
  end
  pri = {pri{1:i-1}}; % trim
end
