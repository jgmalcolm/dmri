function D = tensors(V, d)
  n = size(V,1);
  D = zeros(n, 9);
  for i = 1:n
    v = V(i,:)'; v = v/norm(v);
    a = pi/2*rand;
    v(:,2) = [cos(a) sin(a) 0]';
    a = pi/2*rand;
    v(:,3) = [cos(a) 0 sin(a)]';
    v = gramschmidt(v);
    t = v*d*v';
    D(i,:) = t(:);
  end
end
