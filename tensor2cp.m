function cp = tensor2cp(D)
  n = size(D,2);
  cp = zeros(1,n);
  if n == 0, return, end
  D = reshape(D, 5, 5, []);
  for i = 1:n
    cp(i) = det(D(4:5,4:5,i));
  end
  return

  D = reshape(D([1 2 3 2 4 5 3 5 6],:), 3, 3, []);
  for i = 1:n
    cp(i) = compute_cp(D(:,:,i));
  end
end
    
    
    
function v = compute_cp(D)
  S = sort(eig(D), 1, 'descend');
  assert(S(1) >= S(2) && S(2) >= S(3));
  v = 2*(S(2) - S(3))/sum(S);
end
