function fibers = fiber_mp(fibers, S, u, U, U_lookup)
  
  sz = size(S);
  %ref.M = reshape(ref.M, sz(1), sz(2), 6);
  
  proj = est_watson_proj(U, U_lookup);
  
  n = numel(fibers);
  for i = 1:n
    i
    for j = 1:size(fibers{i},2)
      f = fibers{i}(:,j);
      x = f(1:2);
      
      s = interp2exp(S, x); s = s / norm(s);
      [K M] = proj(s);

%       K = interp2exp(ref.K, x);
%       M = interp2exp(ref.M, x);
%       M = reshape(M, [3 2]);

      X = f(3:end);
      fibers{i}(3:end,j) = reorient(X, K, M);
    end
  end
end
