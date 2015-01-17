% function fig_3cross
%   fn_cc = 'results/tensor_NI/cc/03-20-043940';
%   fn_3x = 'results/tensor_NI/3x';

%   mask = loadsome('matlab', 'mask');
%   [f0 fx] = init_3cross(fn_cc, mask);
%   save([fn_3x '/f0'], 'f0')
%   ijk2tube(fx, [fn_3x '/fx']);
% end

function [f0 fX] = init_3cross(fn, mask, ff)
  
  % gather and connect fibers
%   [f1 f1_] = loadsome([fn '/f_1'], 'f', 'f_');
%   [f2 f2_] = loadsome([fn '/f_2'], 'f', 'f_');
%   f2_ = fiber_connect(f1_, f1_, f2_);
%   ff = {f1_{:} f2_{:}};
%   ff = {ff{~cellfun(@isempty, ff)}};
  
  % has three separate fibers in ROI
  [nx ny nz] = size(mask);
  [xx yy zz] = ndgrid(1:nx, 1:ny, 1:nz);
  roi = nx/2+8 <= xx & xx <= 94;
  roi = roi & 21 <= zz & zz <= 35;
  roi = roi & 50 <= yy & yy <= 95;
  %roi = (xx-85).^2 + (yy-71).^2 + (zz-21).^2 <= 9;
  %roi = (xx-84).^2 + (yy-71).^2 + (zz-20).^2 <= 20;
%   roi = (xx-84).^2 + (yy-73).^2 + (zz-23).^2 <= 4;
  ff = cellfun(@(X) has_3cross(X,roi), ff, 'Un',0);

  ff = {ff{~cellfun(@isempty, ff)}};

  sum(cellfun(@(x)size(x,2), ff))
  
  f0 = cellfun(@form_X0, ff, 'Un',0);
  fX = cellfun(@spikes, ff, 'Un',0);
  fX = [fX{:}];
  fX = mat2cell(fX, size(fX,1), 2*ones(1,size(fX,2)/2));
end

function x = spikes(X)
  [n m] = size(X);
  x = zeros(3, 3*2*m);

  for i = 1:m
    x_ = repmat(X(1:3,i), [1 6]);
    [m1 l1 m2 l2 m3 l3] = state2tensor(X(4:18,i));
    M = [m1 m2 m3] * blkdiag([-1 1], [-1 1], [-1 1]);
    x(1:3, 6*(i-1)+(1:6)) = x_ + M;
  end
end

function X0 = form_X0(X)
  [n m] = size(X);
  X0 = repmat(X, [1 6]);

  [x X P] = deal(X(1:3,:), X(3 + (1:15),:), X(3+15+1:end,:));
  P = reshape(P, 15, 15, []);
  
  for i = 1:m
    x_ = X(:,i);
    p_ = P(:,:,i);
    
    X0(4:end,1*m+i) = [rev(x_); p_(:)]; % reverse first component

    x_ = x_([6:15 1:5]);  % pull up 2nd component
    p_ = p_([6:15 1:5], [6:15 1:5]);
    X0(4:end,2*m+i) = [x_     ; p_(:)];
    X0(4:end,3*m+i) = [rev(x_); p_(:)];
    
    x_ = x_([6:15 1:5]);  % pull up 3rd component
    p_ = p_([6:15 1:5], [6:15 1:5]);
    X0(4:end,4*m+i) = [x_     ; p_(:)];
    X0(4:end,5*m+i) = [rev(x_); p_(:)];
  end
end

function x = rev(x)
  x(1:3) = -x(1:3);
end

function X = has_3cross(X, roi)
  is_roi = roi(sub2ind(size(roi), round(X(1,:)), ...
                                  round(X(2,:)), ...
                                  round(X(3,:))));
  X = X(:,is_roi);
  if isempty(X), return, end

  m1  = X(4:6,:);    fa1 = l2fa(X(7:8,:));
  m2  = X(9:11,:);   fa2 = l2fa(X(12:13,:));
  m3  = X(14:16,:);  fa3 = l2fa(X(17:18,:));
  th12 = acosd(abs(sum(m1.*m2)));
  th13 = acosd(abs(sum(m1.*m3)));
  th23 = acosd(abs(sum(m2.*m3)));
  is_3cross = th12 > 35 & th13 > 35 & th23 > 35;

  is_3cross = is_3cross & (th12>85 | th13>85 | th23>85);
  is_sig    = fa1 > .35 & fa2 > .35 & fa3 > .35;
  X = X(:,is_3cross & is_sig);
end


function n = count_3cross(X)
%   is_roi = roi(sub2ind(size(roi), round(X(1,:)), ...
%                                   round(X(2,:)), ...
%                                   round(X(3,:))));
%   X = X(:,is_roi);
  if isempty(X), n = 0; return, end

  m1  = X(4:6,:);    fa1 = l2fa(X(7:8,:));
  m2  = X(9:11,:);   fa2 = l2fa(X(12:13,:));
  m3  = X(14:16,:);  fa3 = l2fa(X(17:18,:));
  th12 = acosd(abs(sum(m1.*m2)));
  th13 = acosd(abs(sum(m1.*m3)));
  th23 = acosd(abs(sum(m2.*m3)));
  is_3cross = th12 > 35 & th13 > 35 & th23 > 35;
  is_3cross = is_3cross & (th12>85 | th13>85 | th23>85);
  is_sig    = fa1 > .40 & fa2 > .40 & fa3 > .40;

  n = nnz(is_3cross & is_sig);
end


function fa = x2fa(X)
  fa1 = l2fa(X(7:8,:));
  fa2 = l2fa(X(12:13,:));
  fa3 = l2fa(X(17:18,:));
  
  m1  = X(4:6,:);
  m2  = X(9:11,:);
  m3  = X(14:16,:);
  th12 = acosd(abs(sum(m1.*m2)));
  th13 = acosd(abs(sum(m2.*m3)));
  th23 = acosd(abs(sum(m2.*m3)));

  fa = (fa1 + fa2 + fa3)/3;
  fa(fa1 < .25 | fa2 < .25 | fa3 < .25) = 0; % must be anisotropic
  fa(th12 < 85 | th13 < 85 | th23 < 85) = 0; % must be separate
end
