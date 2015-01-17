function [fibers signals odf] = fiber_2sh(S, is_cross, u, th, sh, perms)
  paths;
  
  % Maxime:  L=8   lambda=.006
  % Schultz: L=4   lambda=.004
  
  % use finer tessellation to find maxima
  [Y_ B_ R_ u_ conn_] = MultiResParam(4, []);
  [Y  B  R          ] = MultiResParam(2, []);
  
  % reference directions
  th = th * pi/180;
  M(:,1) = [-1       0       0];
  M(:,2) = [-cos(th) sin(th) 0];
  
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
    Cw = odfestim_fODF(s, u, sh.L, B, Y, R, sh.lambda);
    We = real(Y_*Cw);
    [ex m] = FindODFMaxima(sh.w_min, We/sum(We), conn_, u_, []);
    switch size(m,1)
     case 1
      m = [m;m]; % simply duplicate
     case 2
      % done
     case num2cell(3:sh.max)
      m = min_err(m, M, perms);
     otherwise
      fprintf('.');
      m = m([1 1],:);
    end
    X(3:8,i) = [m(1,:) m(2,:)];
    
    % reconstruct signal from SH
    if nargout >= 2
      [Cs s_] = odfestim(s, u, sh.L, sh.lambda);
      S_(:,i) = s_;
    end
    
    % save fODF
    if nargout == 3
      w = real(Y * Cw);
      W(:,i) = w / sum(w);
    end
  end
  
  fibers = {X};
  signals = {S_};
  odf = {W};
end


function m = min_err(m, M, perms)
  d = abs(m * M); % pairwise inner products
  n = size(m,1);
  p = perms{n};
  p_ = repmat(1:2, size(p,1), 1);
  ind = sub2ind(size(d), p, p_);
  [d_max ind] = max(sum(d(ind),2));
  m = m(p(ind,:),:);
end
