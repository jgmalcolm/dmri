function d = interp2scalar(D, x)
  [nx ny] = size(D);
  % generate indices
  xx = round(x(1)) + [-1 0 1]';
  yy = round(x(2)) + [-1 0 1];
  % clamp
  xx(xx <  1) = 1;  yy(yy <  1) = 1;
  xx(xx > nx) = nx; yy(yy > ny) = ny;
  % grab
  D_ = D(xx,yy);
  
  xx = repmat(xx, [1 3]);
  yy = repmat(yy, [3 1]);
  D_ = reshape(D_, 1, 3^2);
  
  % compute exponential weights
  dist = (xx - x(1)).^2 + (yy - x(2)).^2;
  w = flat(exp( -dist/.7 ));
  
  % weighted sample
  d = D_ * w / sum(w);
end
