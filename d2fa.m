function fa = d2fa(D)
  D_ = D - trace(D)*eye(3)/3;
  fa = sqrt(3/2)*norm(D_,'fro')/norm(D,'fro');
end
