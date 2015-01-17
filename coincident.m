function ind = coincident(x)
  if size(x,2) < 2, ind = 1; return, end
  
  dx = x - x(:,[2 1:end-1]);
  ds = sum(dx.^2);
  ind = (ds == 0);
end
