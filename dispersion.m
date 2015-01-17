function d = dispersion(xx)
  n = size(xx,2);
  
  if n < 3
    d = ones(1,n);
    return
  end
  
  a = xx(1:3,1:end-2);
  b = xx(1:3,2:end-1);
  c = xx(1:3,3:end);
  
  ab = b - a;
  bc = c - b;
  
  ab = ab ./ (sqrt(sum(ab.*ab)) + eps);
  bc = bc ./ (sqrt(sum(bc.*bc)) + eps);
  inner_product = sum(ab .* bc);
  
  d = [1 inner_product 1];  % ignore ends
end
