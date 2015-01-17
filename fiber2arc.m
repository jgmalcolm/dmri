function [xx ss vv] = fiber2arc(ff, m, eig, ff_icp)
  
  % prepare arc-length reference frame  
  [xx yy zz] = ind2sub(size(m), find(m));
  X = [xx yy zz];
  u = mean(X); % center
  [U V] = svd(cov(X));
  v = U(:,eig)'; % reference eigenvector
  v = v/norm(v); % undo scale
  
  ff     = empty(ff    );
  ff_icp = empty(ff_icp);

  % grab position, arc-length, values
  xx = map(@(x)x(1:3,:), ff_icp);
  ss = map(@f2arc,       ff_icp);
  vv = map(@f2v,         ff);
  
  function v = f2v(X)
    x   = X(1:3,:);
    m1  = X(4:6,:);
    l1  = X(7:8,:);
    m2  = X(9:11,:);
    l2  = X(12:13,:);

    fa1 = l2fa(l1);
    fa2 = l2fa(l2);
    dx  = x - x(:,[1 1:end-1]);
    d1  = abs(sum(dx.*m1));
    d2  = abs(sum(dx.*m2));
    is_2 = d2 > d1;
    
    fa_pri = fa1;
    fa_sec = fa2;
    [fa_pri(is_2) fa_sec(is_2)] = deal(fa2(is_2), fa1(is_2));
    
    tr1 = [1 2]*l1 / 1e6;
    tr2 = [1 2]*l2 / 1e6;
    tr_pri = tr1;
    tr_pri(is_2) = tr2(is_2);
    
    norm1 = sqrt(sum([1 0;0 2]*(l1/1e6).^2));
    norm2 = sqrt(sum([1 0;0 2]*(l2/1e6).^2));
    norm_pri = norm1;
    norm_pri(is_2) = norm2(is_2);
    
    rd1 = l1(2,:) ./ l1(1,:);
    rd2 = l2(2,:) ./ l2(1,:);
    rd = rd1;
    rd(is_2) = rd2(is_2);
    
    v = [fa_pri; fa_sec; tr_pri; norm_pri; rd];
  end
  function ds = f2arc(x)
    x = x(1:3,:);

    X_ = center(x,u');
    len = sqrt(sum(X_.^2) + eps);
    X_ = X_ ./ len([1 1 1],:); % normalize
    
    % determine point closest to center
    dd = abs(v * X_);
    is_long = numel(dd) > 25;
    if is_long, dd = dd(10:end-9); end % drop first nine
    [dd ind_mid] = sort(dd); % smallest dot product
    ind_mid = ind_mid(1) + iff(is_long, 9, 0);

    % determine orientation
    is_left = X_(1,ind_mid) - X_(1,ind_mid-1) > 0;
    
    % partition set
    x_ = x(:,ind_mid);
    xL = x(:,1:ind_mid-1);
    xR = x(:,ind_mid+1:end);
    
    xR = xR - [x_ xR(:,1:end-1)];
    xL = xL - [xL(:,2:end) x_];
    
    % centering
    dx = xR(:,1);
    dt = v * dx/norm(dx);
    dx = dt * dx;
    off = norm(dx);
    if dt > 0, off = -off; end

    dsL = sqrt(sum(xL.^2));
    dsR = sqrt(sum(xR.^2));
    
    dsL = dsL(end:-1:1); % flip
    dsL = cumsum(dsL);
    dsL = dsL(end:-1:1); % flip
    dsR = cumsum(dsR);
    
    ds = [-dsL 0 dsR] - off;
    if is_left, ds = -ds; end % flip?
  end
end
