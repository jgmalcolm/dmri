function [xx val] = fiber2ijk(f)
  f = {f{~cellfun(@isempty, f)}};
  xx = map(@(x) x(1:3,:), f); % grab position
  
  % desire FA?
  if nargout == 2
    % 2TW
    %x2val = @(X) X(9,:).*l2fa(X(7:8,:)) + X(15,:).*l2fa(X(13:14,:));
    % 2T
    %x2val = @(X) (l2fa(X(7:8,:)) + l2fa(X(12:13,:)))/2;
    x2val = @x2fa_2t;
    % 1T
    %x2val = @x2fa_1t;
    % 3T
    %x2val = @x2th_3t;

    val = map(x2val, f);
  end
end
function fa = x2fa_1t(f)
  D = f(3 + [1 2 3 2 4 5 3 5 6],:);
  D = reshape(D, 3, 3, []);
  n = size(D,3);
  fa = zeros(1,n);
  for i = 1:n
    fa(i) = d2fa(D(:,:,i));
  end
end


function th = x2th_3t(X)
  x   = X(1:3,:);
  m1  = X(4:6,:);
  m2  = X(9:11,:);
  m3  = X(14:16,:);
  fa1 = l2fa(X(7:8,:));
  fa2 = l2fa(X(12:13,:));
  fa3 = l2fa(X(17:18,:));
  
  th12 = acosd(abs(sum(m1.*m2)));
  th13 = acosd(abs(sum(m2.*m3)));
  th23 = acosd(abs(sum(m2.*m3)));
  
  th = (th12 + th13 + th23)/3;
  th(th12 < 50 | th13 < 50 | th23 < 50) = 0; % must be separate
  th(fa1 < .25 | fa2 < .25 | fa3 < .25) = 0; % must be anisotropic
end


function fa = x2fa_3t(X)
  x   = X(1:3,:);
  m1  = X(4:6,:);
  l1  = X(7:8,:);
  m2  = X(9:11,:);
  l2  = X(12:13,:);
  m3  = X(14:16,:);
  l3  = X(17:18,:);

  fa1 = l2fa(l1); fa2 = l2fa(l2); fa3 = l2fa(l3);
  dx  = x - x(:,[1 1:end-1]);
  d1  = abs(sum(dx.*m1));
  d2  = abs(sum(dx.*m2));
  d3  = abs(sum(dx.*m3));
  is_2 = d2 > d1 & d2 > d3;
  is_3 = d3 > d1 & d3 > d2;
  
  fa = fa1;
  fa(is_2) = fa2(is_2);
  fa(is_3) = fa3(is_3);
end
function fa = x2fa_2t(X)
  x   = X(1:3,:);
  m1  = X(4:6,:);
  l1  = X(7:8,:);
  m2  = X(9:11,:);
  l2  = X(12:13,:);

  fa1 = l2fa(l1); fa2 = l2fa(l2);
  dx  = x - x(:,[1 1:end-1]);
  d1  = abs(sum(dx.*m1));
  d2  = abs(sum(dx.*m2));

  fa = fa1;
  is_2 = d2 > d1;
  fa(is_2) = fa2(is_2);
end
