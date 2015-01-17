function fn  = est_watson_proj(U, lookup)
  fn = @proj;
  
  U = single(U);
  function [k M]  = proj(s)
  % s - input signal
  % U - basis for projection
  % k - vector of scaling parameters
  % M - matrix of principal diffuison directions (in columns)
    [val ind] = max(abs(s' * U));
    k = lookup.k(:,ind);
    M = lookup.M(:,:,ind);
  end
end
