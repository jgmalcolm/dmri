function fn  = est_proj(U, lookup)
  fn = @proj;
  
  function X  = proj(s)
  % s - input signal
  % U - normalized basis for projection
  % X - state of lambda/directions
    [val ind] = max(abs(s' * U) / norm(s));
    X = lookup(:,ind);
  end
end
