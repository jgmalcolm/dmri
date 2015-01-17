function [fibers signals odf] = fiber_sh_t(S, is_cross, u, conn, th, L, lambda)
  
  % Maxime:  L=8   lambda=.006
  % Schultz: L=4   lambda=.004
    
  % use finer tessellation to find maxima
  u_ = icosahedron(4);
  Y_ = makespharms(u_, 0);
  for l = 2:2:L
    Y_ = [Y_ makespharms(u_,l)];
  end

  % reference directions
  th = th * pi/180;
  M = [[-1       0       0]' ...
       [-cos(th) sin(th) 0]'];
  
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
    s = flat(SS(i,:)); s = s / norm(s);
    % determine directions
    [Cs Se Cw w] = odfestim_fODF(s, u, L, lambda);
    We = real(Y_*Cw);
    We = We/sum(We);
    m = FindODFMaxima(We,conn,u_);
    n = size(m,1);
    if n == 1
      m = [m;m]; % duplicate
    elseif n > 2
      % pick two closest to what we're looking for
      d = abs(m * M); % pairwise inner products
      d_max = 0;
      for j = 1:n
        for k = setxor(j,1:n)
          d_ = max(d(j,1)+d(k,2), d(j,2)+d(k,1));
          if d_ > d_max
            d_max = d_;
            ind = [j k];
          end
        end
      end
      m = m(ind,:);
    end
    % Watson
    X(3:10,i) = [m(1,:) 1 m(2,:) 1];  % nb: K=1
    % Tensor
    %X(3:12,i) = [m(1,:) [1200 100]   m(2,:) [1200 100]];
    
    % reconstruct signal from SH
    if nargout >= 2
      [Cs s_] = odfestim(s, u, L, lambda);
      S_(:,i) = s_ / norm(s_);
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
