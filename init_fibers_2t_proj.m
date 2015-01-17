function pri = init_fibers_2t_proj(S, seeds, u, b, param)
  paths;
  
  [U U_lookup] = loadsome('tensor_2fiber_01045', 'U', 'U_lookup');
  proj = est_proj(U, U_lookup);

  fprintf('initial seed voxels: %d\n', nnz(seeds));

  randn('state', 0);
  E = randn(3, param.seeds); E = E * diag(1./(sqrt(sum(E.^2)) + eps)) / 2;
  
  P = flat(eye(length(proj(flat(S(1,1,1,[1:end 1:end])+eps)))));

  % estimate initial state
  [x(1,:) x(2,:) x(3,:)] = ind2sub(size(seeds), find(seeds));
  n = nnz(seeds) * size(E,2) * 4;
  pri = cell(1,n);
  fprintf('initial seed upper limit: %d\n', n);
  per = 1;
  i = 0;
  for x = x
    for e = E
      X = proj(interp3exp(S, x+e));
      [m1 l1 m2 l2] = state2tensor(X);
      if m1'*m2 < 0,  m2 = -m2; end % same general direction
      is_one = l2fa(l1) >= param.FA_min;
      is_two = l2fa(l2) >= param.FA_min;
      if is_one
        pri{i+1} = [x+e;  m1; l1;  m2; l2; P];
        pri{i+2} = [x+e; -m1; l1; -m2; l2; P];
        i = i + 2;
      end
      if is_two && m1'*m2 < 1
        pri{i+1} = [x+e;  m2; l2;  m1; l1; P];
        pri{i+2} = [x+e; -m2; l2; -m1; l1; P];
        i = i + 2;
      end
      if 100*i/n >= per + 2
        fprintf('  %d of %d  [%.0f%%]\n', i, n, i / n * 100);
        per = round(100*i/n) + 1;
      end
    end
  end
  pri = {pri{1:i}}; % trim
end
