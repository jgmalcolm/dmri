function xx = half(xx)
  if size(xx{1},1) > 3
    xx = map(@(x) x(1:3,:), xx);
  end
  
  xx = map(@(x) x(:,x(1,:) >= 72), xx);
  xx = xx(~cellfun(@has_gap, xx));
  xx = xx(cellfun(@(x)size(x,2) > 2, xx));
  xx = map(@(x)   x(:,~coincident(x)), xx);
  xx = empty(xx);
end
