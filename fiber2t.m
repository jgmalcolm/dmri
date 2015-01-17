function ff = fiber2t(ff, u, b, S, param)
% direct, unconstrained tensor estimation
  
  v = param.voxel;
  % precompute
  ux = u(:,1); uy = u(:,2); uz = u(:,3);
  B = -b * [ux.^2  2*ux.*uy  2*ux.*uz  uy.^2  2*uy.*uz  uz.^2];

  ff = map(@f2t, ff);

  function X = f2t(X)
    if isempty(X), return, end
    % grab signal from all those locations
    xx = X(1:3,:);
    n = size(X,2);
    s = zeros(size(u,1), n);
    for i = 1:n
      s(:,i) = interp3exp(S, X(1:3,i), v);
    end
    % estimate tensors
    D = real(B \ log(s)); % ensure real since unconstrained est
    
    X = [xx; D];
  end
end
