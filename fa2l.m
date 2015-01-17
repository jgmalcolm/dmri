function l2 = fa2l(l1, fa)
  l2 = (l1 - l1.*fa.*sqrt(3-2.*fa.^2))./(1-2.*fa.^2);
end
