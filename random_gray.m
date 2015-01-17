function vv = random_gray(xx, n)
  vv = map(@(x) ceil(n*rand)*ones(1,size(x,2)), xx);
end
