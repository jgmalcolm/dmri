function dd = fibers2tensors(tract, u, b, ff)
  
  dd = cell(size(ff));
  for i = 1:numel(ff)
    dd{i} = map(@(f) ff2dd(f,u,b,tract(i).S), ff{i});
  end
end

function D = ff2dd(X, u, b, S)
% direct, unconstrained tensor estimation

  % precompute
  ux = u(:,1); uy = u(:,2); uz = u(:,3);
  B = -b * [ux.^2  2*ux.*uy  2*ux.*uz  uy.^2  2*uy.*uz  uz.^2];
  
    % grab signal from all those locations
    n = size(X,2);
    s = zeros(size(u,1), n);
    for i = 1:n
      s(:,i) = interp2exp(S, X(1:2,i));
    end
    % estimate tensors
    D = real(B \ log(s)); % ensure real since unconstrained est
end
