function f = kill_curvature(f, param)
  curv = curvature(f);
  
  radius = 1 ./ curv;
  ind = find(radius < 0.87, 1, 'first');
  
  if isempty(ind), return, end % all okay
  
  f = f(:,1:ind);
end
