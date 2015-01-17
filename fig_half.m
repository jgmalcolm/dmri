function [xx vv] = fig_half(xx, vv)
  if nargin == 1
    vv = map(@x2fa, xx);
  end
  xx = map(@(x) x(1:3,:), xx);
  
  vv = map(@(x,v) v(:,x(1,:) >= 72), xx, vv);
  xx = map(@(x)   x(:,x(1,:) >= 72), xx);
  
  vv = vv(~cellfun(@has_gap, xx));
  xx = xx(~cellfun(@has_gap, xx));
  
  vv = vv(cellfun(@(x)size(x,2) > 2, xx));
  xx = xx(cellfun(@(x)size(x,2) > 2, xx));
  
  vv = map(@(x,v) v(:,~coincident(x)), xx, vv);
  xx = map(@(x)   x(:,~coincident(x)), xx);

  vv = empty(vv);
  xx = empty(xx);
  
  assert(numel(vv) == numel(xx));
  cellfun(@(x,v) assert(size(x,2)==size(v,2)), xx, vv);
  
end


function fa = x2fa(X)
  n = size(X,2);
  fa = zeros(1,n);
  X = double(X);
  for i = 1:n
    [m1 l1 m2 l2] = state2tensor(X(:,i));
    fa(i) = l2fa(l1) + l2fa(l2);
  end
  fa = fa / 2;
end
