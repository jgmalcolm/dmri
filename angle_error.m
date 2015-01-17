function e = angle_error(ff, th, w, param)
  th = pi*th/180;
  e = map(@(f) fiber2error_2T(f,th,w,param), ff);
  e = [e{:}];
end

function e = fiber2error_2T(f, th, w, param)
  if size(f,1) == 12, f = f(3:end,:); end % drop coordinates
  n = size(f,2);
  e = zeros(1,n);
  M1 = [-1 0 0]';
  M2 = [-cos(th) sin(th) 0]';
  for i = 1:n
    e(i) = err(f(:,i));
  end

  function e = err(X)
    [m1 l1 m2 l2] = state2tensor(X);
    % same angle?
    if th > pi*10/180 && abs(m1' * m2) > cos(5*pi/180)   % HACK
      e = inf;
      return;
    end
    % compute distances to first
    e11 = acos(abs(m1' * M1));
    e12 = acos(abs(m1' * M2));
    % compute distances to second
    e21 = acos(abs(m2' * M1));
    e22 = acos(abs(m2' * M2));
    % compute eigenvalue tests
    is_1 = l2fa(l1) > param.FA_min;
    is_2 = l2fa(l2) > param.FA_min;
    if is_1 && is_2
      e = min(w*e11 + (1-w)*e22, (1-w)*e12 + w*e21);
    else
      e = inf; % isotropic
    end
  end
end





function e = fiber2error_hot(f, M, param)
  if isempty(f), e = []; return; end
  n = size(f,2);
  e = zeros(1,n);
  for i = 1:n
    x = f(1:2,i);
    m1 = interp2exp(M(:,:,:,1), x);
    m2 = interp2exp(M(:,:,:,2), x);
    e(:,i) = err(f(3:end,i), m1/norm(m1), m2/norm(m2));
  end

  function e = err(X, M1, M2)
    [m1 w1 k1 m2 w2 k2] = unpack(X);
    % same angle?
    if abs(m1' * m2) > cos(5*pi/180)   % HACK
      e = inf;
      return;
    end
    % compute distances to first
    e11 = acos(abs(m1' * M1));
    e12 = acos(abs(m1' * M2));
    % compute distances to second
    e21 = acos(abs(m2' * M1));
    e22 = acos(abs(m2' * M2));
    is_1 = w1/max(w1,w2) > .2 && k1/max(k1,k2) > .3;
    is_2 = w2/max(w1,w2) > .2 && k2/max(k1,k2) > .3;
    if is_1 && is_2
      % compute eigenvalue tests
      if e12 + e21 < e11 + e22
        e = e12 + e21;
      else
        e = e11 + e22;
      end
    else
      e = inf; % fail
    end
  end

  function [m1 w1 k1 m2 w2 k2] = unpack(X)
    m1 = X(1:3); m1 = m1 / norm(m1);
    w1 = X(4);
    k1 = X(5);
    m2 = X(6:8); m2 = m2 / norm(m2);
    w2 = X(9);
    k2 = X(10);
  end
end

function e = fiber2error_3T(f, th, w, param)
  if size(f,1) == 17, f = f(3:end,:); end % drop coordinates
  n = size(f,2);
  e = zeros(1,n);
  M1 = [-1 0 0]';
  M2 = [-cos(th) sin(th) 0]';
  M3 = [-cos(th) cos(th)*(1-cos(th))/sin(th)];
  M3(3) = sqrt(1 - norm(M3)^2);

  for i = 1:n
    e(i) = err(f(:,i));
  end

  function e = err(X)
    [m1 l1 m2 l2 m3 l3] = state2tensor(X);
    d12 = abs(m1'*m2); d13 = abs(m1'*m3); d23 = abs(m2'*m3);
%     def = acos(abs(M1'*M2))/2;
    def = inf;
    c = cos(5*pi/180);
    if d12 > c || d13 > c || d23 > c  % HACK
      e = def;
      return;
    end
    % compute eigenvalue tests
    is_1 = l2fa(l1) > param.FA_min;
    is_2 = l2fa(l2) > param.FA_min;
    is_3 = l2fa(l3) > param.FA_min;
    if is_1 && is_2 && is_3
      % compute distances to first
      e11 = acos(abs(m1' * M1));
      e12 = acos(abs(m1' * M2));
      e13 = acos(abs(m1' * M3));
      % compute distances to second
      e21 = acos(abs(m2' * M1));
      e22 = acos(abs(m2' * M2));
      e23 = acos(abs(m2' * M3));
      % compute distances to third
      e31 = acos(abs(m3' * M1));
      e32 = acos(abs(m3' * M2));
      e33 = acos(abs(m3' * M3));
      e = min([e11 + e22 + e33 ...
               e11 + e23 + e32 ...
               e12 + e21 + e33 ...
               e12 + e23 + e31 ...
               e13 + e22 + e31 ...
               e13 + e21 + e32]) / 3;
    else
      e = def; % isotropic
    end
  end
end

function e = fiber2error_2W(f, M, param)
  if isempty(f), e = []; return; end
  n = size(f,2);
  e = zeros(1,n);
  for i = 1:n
    x = f(1:2,i);
    m1 = interp2exp(M(:,:,:,1), x);
    m2 = interp2exp(M(:,:,:,2), x);
    e(i) = error_2W(f(3:end,i), ...
                    m1/norm(m1), m2/norm(m2), ...
                    param);
  end
end
function e = error_2W(X, M1, M2, param)
  [m1 k1 m2 k2] = state2watson(X);
  % same angle?
  if abs(m1' * m2) > cos(5*pi/180)   % HACK
    e = inf;
    return;
  end
  % compute distances to first
  e11 = acos(abs(m1' * M1));
  e12 = acos(abs(m1' * M2));
  % compute distances to second
  e21 = acos(abs(m2' * M1));
  e22 = acos(abs(m2' * M2));
  is_1 = k1 > param.k_min;
  is_2 = k2 > param.k_min;
  if is_1 && is_2
    e = min(e12 + e21, e11 + e22)/2;
  elseif is_1
    e = min(e11, e12);
  elseif is_2
    e = min(e21, e22);
  else
    e = inf; % isotropic
  end
end



function e = fiber2error_3W(f, M, param)
  if isempty(f), e = []; return; end
  n = size(f,2);
  e = zeros(1,n);
  for i = 1:n
    [x o1 o2 o3] = unpack_3w(f(:,i));
    m1 = interp2exp(M(:,:,:,1), x);
    m2 = interp2exp(M(:,:,:,2), x);
    m3 = interp2exp(M(:,:,:,3), x);
    e(i) = error_3w(o1,          o2,          o3,          ...
                    m1/norm(m1), m2/norm(m2), m3/norm(m3), ...
                    param);
  end
end
function e = error_3w(o1,o2,o3, M1,M2,M3, param)
  [m1 k1] = unpack_watson(o1);
  [m2 k2] = unpack_watson(o2);
  [m3 k3] = unpack_watson(o3);
  % compute distances to first
  e11 = acos(abs(m1' * M1));
  e12 = acos(abs(m1' * M2));
  e13 = acos(abs(m1' * M3));
  % compute distances to second
  e21 = acos(abs(m2' * M1));
  e22 = acos(abs(m2' * M2));
  e23 = acos(abs(m2' * M3));
  % compute distances to third
  e31 = acos(abs(m3' * M1));
  e32 = acos(abs(m3' * M2));
  e33 = acos(abs(m3' * M3));
  % strength of each fiber
  is_1 = k1 > param.k_min;
  is_2 = k2 > param.k_min;
  is_3 = k3 > param.k_min;
  
  % which angles should we check
  d12 = abs(m1'*m2);
  d13 = abs(m1'*m3);
  d23 = abs(m2'*m3);
  
  if is_1 && is_2 && is_3
    e = min([e11 + e22 + e33 ...
             e11 + e23 + e32 ...
             e12 + e21 + e33 ...
             e12 + e23 + e31 ...
             e13 + e22 + e31 ...
             e13 + e21 + e32]) / 3;
  elseif is_1 && is_2
    e = min([e11 + e22 ...
             e11 + e23 ...
             e12 + e21 ...
             e12 + e23 ...
             e13 + e21 ...
             e13 + e22]) / 2;
  elseif is_1 && is_3
    e = min([e11 + e32 ...
             e11 + e33 ...
             e12 + e31 ...
             e12 + e33 ...
             e13 + e32 ...
             e13 + e33]) / 2;
  elseif is_2 && is_3
    e = min([e21 + e32 ...
             e21 + e33 ...
             e22 + e31 ...
             e22 + e33 ...
             e23 + e31 ...
             e23 + e32]) / 2;
  elseif is_1
    e = min([e11 e12 e13]);
  elseif is_2
    e = min([e21 e22 e23]);
  elseif is_3
    e = min([e31 e32 e33]);
  else
    e = inf; % isotropic
  end
end


function e = fiber2error_2TW(f, M, th, w, param)
  if isempty(f), e = []; return; end
  n = size(f,2);
  e = zeros(2,n);
  if size(f,1) == 11
    m1 = [-1 0 0]';
    m2 = [-cos(th) sin(th) 0]';
    for i = 1:n
      e(:,i) = err(f(:,i), m1, m2);
    end
  elseif size(f,1) == 13
    for i = 1:n
      x = f(1:2,i);
      m1 = interp2exp(M(:,:,:,1), x);
      m2 = interp2exp(M(:,:,:,2), x);
      e(:,i) = err(f(3:end,i), m1/norm(m1), m2/norm(m2));
    end
  end

  function e = err(X, M1, M2)
    [m1 l1 w1 m2 l2] = state2tensorW(X);
    w2 = 1 - w1;
    % same angle?
    if abs(m1' * m2) > cos(5*pi/180)   % HACK
      e = inf(2,1);
      return;
    end
    % compute distances to first
    e11 = acos(abs(m1' * M1));
    e12 = acos(abs(m1' * M2));
    % compute distances to second
    e21 = acos(abs(m2' * M1));
    e22 = acos(abs(m2' * M2));
    % compute eigenvalue tests
    is_1 = l2fa(l1) > param.FA_min && w1 > (1-w)-.15;
    is_2 = l2fa(l2) > param.FA_min && w2 > (1-w)-.15;
    if is_1 && is_2
      a = w1*e12 + w2*e21;
      b = w1*e11 + w2*e22;
      if a < b,   e = [a; w2];
      else        e = [b; w1]; end
    else
      e = inf(2,1); % undetected
    end
  end
end


function e = fiber2error_3TW(f, M, param)
  if isempty(f), e = []; return; end
  n = size(f,2);
  e = zeros(2,n);
  for i = 1:n
    x = f(1:2,i);
    m1 = interp2exp(M(:,:,:,1), x); m1 = m1/norm(m1);
    m2 = interp2exp(M(:,:,:,2), x); m2 = m2/norm(m2);
    m3 = interp2exp(M(:,:,:,3), x); m3 = m3/norm(m3);
    e(:,i) = err(f(3:end,i), m1, m2, m3);
  end

  function e = err(X, M1, M2, M3)
    [m1 l1 w1 m2 l2 w2 m3 l3 w3] = state2tw(X);
    d12 = abs(m1'*m2); d13 = abs(m1'*m3); d23 = abs(m2'*m3);
    def = inf;
    c = cos(5*pi/180);
    if d12 > c || d13 > c || d23 > c
      e = def;
      return;
    end
    % compute eigenvalue tests
    is_1 = l2fa(l1) > param.FA_min && w1 > param.w_min;
    is_2 = l2fa(l2) > param.FA_min && w2 > param.w_min;
    is_3 = l2fa(l3) > param.FA_min && w3 > param.w_min;
    if is_1 && is_2 && is_3
      % compute distances to first
      e11 = w1*acos(abs(m1' * M1));
      e12 = w1*acos(abs(m1' * M2));
      e13 = w1*acos(abs(m1' * M3));
      % compute distances to second
      e21 = w2*acos(abs(m2' * M1));
      e22 = w2*acos(abs(m2' * M2));
      e23 = w2*acos(abs(m2' * M3));
      % compute distances to third
      e31 = w3*acos(abs(m3' * M1));
      e32 = w3*acos(abs(m3' * M2));
      e33 = w3*acos(abs(m3' * M3));
      [e ind] = min([e11 + e22 + e33 ...
                     e11 + e23 + e32 ...
                     e12 + e21 + e33 ...
                     e12 + e23 + e31 ...
                     e13 + e22 + e31 ...
                     e13 + e21 + e32]);
      lookup = [w1 w1 w2 w3 w3 w2];
      e(2) = lookup(ind);
    else
      e = def; % isotropic
    end
  end
end
