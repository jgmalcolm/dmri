function fibers = fiber_pp(S, is_cross, u, proj)
  
  [X(1,:) X(2,:)] = find(is_cross);
  
  % dimension
  ii = 3:3+numel(proj(flat(S(1,1,:))))-1;

  for i = 1:nnz(is_cross)
    s = flat(S(X(1,i),X(2,i),:));
    X(ii,i) = proj(s / norm(s));
  end
  
  fibers = {X};
end
