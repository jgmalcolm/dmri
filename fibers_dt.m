function ff = fibers_dt(ff, S, u, b)
  
  ux = u(:,1); uy = u(:,2); uz = u(:,3);
  B = -b * [ux.^2  2*ux.*uy  2*ux.*uz  uy.^2  2*uy.*uz  uz.^2];
  
  ff = map(@conv, ff);
  
  function y = conv(x)
    n = size(x,2);
    y = zeros(2+5,n);
    y(1:2,:) = x(1:2,:);
    for i = 1:n
      D = real(B \ log(interp2exp(S, y(1:2,i))));
      [U V] = svd(D([1 2 3; 2 4 5; 3 5 6]));
      m = U(:,1);
      l = [V(1); (V(5)+V(9))/2]*1e6;
      assert(l(1) > l(2));
      y(3:7,i) = [m;l];
    end
  end

end
