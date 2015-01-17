function [X I] = tri2lin(xx)
  n = numel(xx);

  X = zeros(1,3*n, 'single');
  I = zeros(1,n,   'uint32');
  
  nn = cumsum(cellfun(@(x) size(x,2), xx));
  
  X = reshape([xx{:}], 1, []);
  I = [0 nn(1:end-1)];  % zero-based index into X
end
