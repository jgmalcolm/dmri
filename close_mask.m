function m = close_mask(m, n)
  if nargin == 1, n = 3; end
  if n == 0, return, end
  [xx yy zz] = ndgrid((1:n) - (n+1)/2);
  N = xx.^2 + yy.^2 + zz.^2 <= (n/2)^2;
  m = imclose(m, strel(N));
end
