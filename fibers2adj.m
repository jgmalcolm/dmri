function [A lbl] = fibers2adj(ff, m)
  lbl = unique(m(m > 0));
  n = numel(lbl);
  A = zeros(n);
  
  % enflate ROIs
  sz = size(m);
  M = zeros([size(m) n]);
  for i = 1:n
    M(:,:,:,i) = close_mask(m == lbl(i));
  end
  M = reshape(M, [], n);
  
  % find where present and increment
  for i = 1:numel(ff)
    f = round(ff{i});
    [self rest] = fiber2id(f, M, sz);
    A(self,rest) = A(self,rest) + 1;
  end
  
end


function [self rest] = fiber2id(f, M, sz)
  % find ID of self
  ind = sub2ind(sz, f(1), f(2), f(3));
  self = find(M(ind,:));
  
  % find ID of rest
  ind = sub2ind(sz, f(1,2:end), f(2,2:end), f(3,2:end));
  rest = find(any(M(ind,:)));
end
