function r = has_gap(x)
  r = false;
  if size(x,2) < 2, return, end
  
  ds = sum((x(:,2:end) - x(:,1:end-1)).^2);
  
  r = any(ds > 2);  
end
