function fa = x2fa_2T(x)
  x   = X(1:3,:);
  m1  = X(4:6,:);
  l1  = X(7:8,:);
  m2  = X(9:11,:);
  l2  = X(12:13,:);

  fa1 = l2fa(l1);
  fa2 = l2fa(l2);
  dx  = x - x(:,[1 1:end-1]);
  d1  = abs(sum(dx.*m1));
  d2  = abs(sum(dx.*m2));
  is_2 = d2 > d1;
  
  fa = fa1;
  fa(is_2) = fa2(is_2);
end
