function pri = init_fibers_1t(S, seeds, u, b, param)
  paths;
  
  % 1T direct estimation setup
  ux = u(:,1); uy = u(:,2); uz = u(:,3);
  B = -b * [ux.^2  2*ux.*uy  2*ux.*uz  uy.^2  2*uy.*uz  uz.^2];
  
  fprintf('initial seed voxels: %d\n', nnz(seeds));
  
  randn('seed',0);
  E = randn(3, param.seeds); E = E * diag(1./(sqrt(sum(E.^2)) + eps)) / 2;
  
  P = param.P0(:);
  v = param.voxel;
  
  % HACK
  seeds = false(size(seeds));
  seeds(73,70,28) = true;
  E = [0 0 0]';

  % estimate initial state
  [x(1,:) x(2,:) x(3,:)] = ind2sub(size(seeds), find(seeds));
  n = nnz(seeds) * size(E,2) * 2;
  
  pri = cell(1,n);
  fprintf('initial seed upper limit: %d\n', n);
  per = 1;
  i = 0;
  for x = x
    for e = E
      D = real(B \ log(interp3exp(S, x+e, v))); % ensure real
      if any(isinf(D(:)) | isnan(D(:))), continue, end
      [U V] = svd(D([1 2 3; 2 4 5; 3 5 6]));
      m = U(:,1);
      l = [V(1); (V(5)+V(9))/2]*1e6;
      
      if l2fa(l) >= param.FA_min && l(1) > l(2)
        pri{i+1} = [x+e;  m; l; P];
        %pri{i+2} = [x+e; -m; l; P];
        %i = i + 2;
        i = i + 1;
      end

      if 100*i/n >= per + 2
        fprintf('[%3.0f%%] (%7d - %7d)\n', 100*i/n, i, n);
        per = round(100*i/n) + 1;
      end
    end
  end
  pri = pri(1:i); % trim
end
