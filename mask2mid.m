function m_ = mask2mid(m, hx)
  [xx yy zz] = ind2sub(size(m), find(m));
  D = cov([xx yy zz]);
  [U V] = svd(D);
  x = U(:,2); % second eigenvector
  
  [nx ny nz] = size(m);
  xx_ = xx - nx/2; yy_ = yy - ny/2; zz_ = zz - nz/2; % center
  d = 1 ./ sqrt(xx_.^2 + yy_.^2 + zz_.^2 + eps);
  xx_ = xx_ .* d; yy_ = yy_ .* d; zz_ = zz_ .* d; % normalize

  dd = abs([xx_ yy_ zz_] * x); % dot product
  ind = find(dd < hx); % what is orthogonal?  (within tolerance)
  
  ind = sub2ind(size(m), xx(ind), yy(ind), zz(ind));
  
  m_ = false(size(m));
  m_(ind) = true;
  
  m_ = close_mask(m_, 3);
end
