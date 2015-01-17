clf
n = size(F,2);

for i = 1:n
  x = F(1,i); y = F(2,i);
  M = reshape(F([3 4 5 9 10 11],i), [3 2]);
  s = flat(S(x,y,:))/2;
  odf_axes(s, u, M, [x y 0]');
end
