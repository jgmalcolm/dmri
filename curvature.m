function curv = curvature(xx)
  n = size(xx,2);
  
  if n < 3
    curv = zeros(1,n);
    return
  end
  
  a = xx(1:3,1:end-2);
  b = xx(1:3,2:end-1);
  c = xx(1:3,3:end);
  
  ab = b - a;
  bc = c - b;
  
  ab_ = sqrt(sum(ab.^2)) + eps;
  bc_ = sqrt(sum(bc.^2)) + eps;
  
  num = bsxfun(@rdivide, bc, bc_) - bsxfun(@rdivide, ab, ab_);
  den = ab_ + bc_;

  curv = bsxfun(@rdivide, num, den);
  curv = 2*sqrt(sum(curv.^2));

  curv(isnan(curv)) = 0;
  
  curv = curv([1 1:end end]); % replicate
end
