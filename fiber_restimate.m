function fibers = fiber_ref(fibers, S, u, ref)
  
  sz = size(ref.M);
  ref.M = reshape(ref.M, sz(1), sz(2), 6);

  n = numel(fibers);
  for i = 1:n
    for j = 1:size(fibers{i},2)
      f = fibers{i}(:,j);
      x = f(1:2);

      K = interp2exp(ref.K, x);
      M = interp2exp(ref.M, x);
      M = reshape(M, [3 2]);

      X = f(3:end);
      fibers{i}(3:end,j) = reorient(X, K, M);
    end
  end
end
