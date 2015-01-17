function fa = xx2fa(x, u, b, S)
  x = double(x);
  n = size(x,2);
  s = zeros(2*size(S,ndims(S)), n);
  for i = 1:n
    s(:,i) = interp3exp(S, x(1:3,i));
  end
  
  [d D] = direct_1T(u, b, s);
  fa = zeros(1,n);
  for i = 1:n
    fa(i) = d2fa(D(:,:,i));
  end
end
