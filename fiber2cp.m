function [cp fa dm dl] = fiber2cp(ff, u, b, S, param)
% direct, unconstrained tensor estimation
  
  v = param.voxel;
  % precompute
  ux = u(:,1); uy = u(:,2); uz = u(:,3);
  B = -b * [ux.^2  2*ux.*uy  2*ux.*uz  uy.^2  2*uy.*uz  uz.^2];
  
  ff = empty(ff);

  [cp fa] = maps(@f2single, ff);
  [dm dl] = maps(@f2cov,    ff);
  
  function [cp fa] = f2single(X)
    % grab signal from all those locations
    xx = X(1:3,:);
    n = size(X,2);
    s = zeros(size(u,1), n);
    for i = 1:n
      s(:,i) = interp3exp(S, X(1:3,i), v);
    end
    % estimate tensors
    D = real(B \ log(s)); % ensure real since unconstrained est
    D = reshape(D([1 2 3 2 4 5 3 5 6],:), 3, 3, []);
    % compute tensor measures
    cp = zeros(1,n);
    fa = cp;
    for i = 1:n
      d = D(:,:,i);
      cp(i) = compute_cp(d);
      fa(i) = tensor2fa(d);
    end
  end
  
  function [dm dl] = f2cov(X)
    n = size(X,2);
    P = X(9:end,:);
    P = reshape(P, 5, 5, []);
    dm = zeros(1,n); dl = dm;
    for i = 1:n
      dm(i) = det(P(1:3,1:3,i));
      dl(i) = det(P(4:5,4:5,i));
    end
  end
end

function v = compute_cp(D)
  S = sort(eig(D), 1, 'descend');
  assert(S(1) >= S(2) && S(2) >= S(3));
  v = 2*(S(2) - S(3))/sum(S);
end
