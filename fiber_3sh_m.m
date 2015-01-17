function [fibers signals odf] = fiber_3sh_m(S, is_cross, u, th, L, lambda)
  paths;
  
  % Maxime:  L=8   lambda=.006
  % Schultz: L=4   lambda=.004

  for res = 1:4
    [Y B R u_ conn_] = MultiResParam(res,[]);
    param.B{res} = B;
    param.Y{res} = Y;
    param.u{res} = u_;
    param.conn{res} = conn_;
  end
  [param.gradY, param.gradB, param.gradR, dumy,dumy] = MultiResParam(0, u);

  param.lambda = lambda;
  param.L = L;
  param.grads = u;

  % reference directions
  th = th * pi/180;
  M(:,1)   = [-1       0       0];
  M(:,2)   = [-cos(th) sin(th) 0];
  M(1:2,3) = [-cos(th) cos(th)*(1-cos(th))/sin(th)];
  M(3,3)   = sqrt(1-norm(M(1:2,3))^2);
  
  % gather signals to estimate on
  m = size(S,ndims(S));
  if islogical(is_cross)
    n = nnz(is_cross);
    [X(1,:) X(2,:)] = find(is_cross);
    S = reshape(S, [], m);
    SS = S(is_cross,:);
  else
    n = size(is_cross,2);
    X = is_cross;
    SS = zeros(n, m); 
    for i = 1:n
      SS(i,:) = interp2exp(S, X(:,i));
    end
  end
  
  S_ = zeros(size(S,ndims(S)), n);
  W = zeros(size(S,ndims(S)), n);
  
  for i = 1:n
    s = flat(SS(i,:));
    % determine directions
    [m ga w] = EstimatePDD(s, param);
    m = m';
    switch size(m,1)
     case 1
      m = [m;m;m]; % simply duplicate
     case 2
      % duplicate whichever minimizes error
      m = min_err([m;m], M);
     case 3
      % done
     case {4,5,6,7,8,9,10,11}
      m = min_err(m, M);
     otherwise
      fprintf('.');
      m = m([1 1 1],:);
    end
    X(3:11,i) = [m(1,:) m(2,:) m(3,:)];
    
    % reconstruct signal from SH
    if nargout >= 2
      [Cs s_] = odfestim(s, u, L, lambda);
      S_(:,i) = s_;
    end
    
    % save fODF
    if nargout == 3
      W(:,i) = w / sum(w);
    end
  end
  
  fibers = {X};
  signals = {S_};
  odf = {W};
end


function m = min_err(m, M)
  d = abs(m * M); % pairwise inner products
  n = size(m,1);
  P = perms(1:n);
  P = P(:,1:3);
  P_ = repmat(1:3, size(P,1), 1);
  ind = sub2ind(size(d), P, P_);
  [d_max ind] = max(sum(d(ind),2));
  m = m(P(ind,:),:);
end
