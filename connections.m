function [ff vv] = connections(A, lbl, m)
  
  n = numel(lbl);

  disp('determine centroids...');
  C = [];
  for i = 1:n
    ind = find(close_mask(m == lbl(i)));
    [xx yy zz] = ind2sub(size(m), ind);
    c = mean([xx yy zz]);
    C(:,end+1) = c;
  end
  
  disp('record connections...');
  ff = {};
  vv = {};
  for i = 1:n
    for j = setxor(i,1:n)
      v = A(i,j) + A(j,i); % force symmetric
      ff = {ff{:} C(:,[i j])};
      vv = {vv{:} [v v]};
    end
  end
end
