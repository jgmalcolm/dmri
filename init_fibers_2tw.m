function pri = init_fibers_2tw(S, seeds, u, b, param)
  paths;
  
  % 1T direct estimation setup
  ux = u(:,1); uy = u(:,2); uz = u(:,3);
  B = -b * [ux.^2  2*ux.*uy  2*ux.*uz  uy.^2  2*uy.*uz  uz.^2];

  fprintf('initial seed voxels: %d\n', nnz(seeds));
  
  randn('state',0);
  E = randn(3, param.seeds); E = E * diag(1./(sqrt(sum(E.^2)) + eps)) / 2;

  P = flat(eye(11));
  v = param.voxel;

  % estimate initial state
  [x(1,:) x(2,:) x(3,:)] = ind2sub(size(seeds), find(seeds));
  n = nnz(seeds) * size(E,2) * 2;
  pri = cell(1,n);
  fprintf('initial seed upper limit: %d\n', n);
  per = 1;
  i = 0;
  for x = x
    for e = E
      D = real(B \ log(interp3exp(S, x+e, v))); % ensure real since unconstrained
      if any(isinf(D(:)) | isnan(D(:))), continue, end
      [U V] = svd(D([1 2 3; 2 4 5; 3 5 6]));
      m = U(:,1);
      l = [V(1); (V(5)+V(9))/2]*1e6;

      if l2fa(l) >= param.FA_min
        pri{i+1} = [x+e;  m; l; .9;  m; l; P];
        pri{i+2} = [x+e; -m; l; .9; -m; l; P];
        i = i + 2;
      end

      if 100*i/n >= per + 2
        fprintf('[%3.0f%%] (%7d - %7d)\n', 100*i/n, i, n);
        per = round(100*i/n) + 1;
      end
    end
  end
  pri = pri(1:i); % trim
end
