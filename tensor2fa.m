function fa = tensor2fa(T)
  T_ = trace(T)/3;
  fa = sqrt(3/2) * norm(T - T_*eye(3)) / norm(T);
end
