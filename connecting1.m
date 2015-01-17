% function ff_ = connecting(ff, A, B, C, D_)
function ff_ = connecting(ff, A, B)
% fibers touching (A,B,C) but not (D_)
  
  n = numel(ff);
  ff_ = cell(1,n);
  cnt = 0;
  A  = close_mask(A);
  B = close_mask(B);
  
  [nx ny nz] = size(A);
% % 
%   is_C = (nargin <= 4) && ~isempty(C);
%   is_D = (nargin <= 5) && ~isempty(D_);

  for i = 1:n
    % unpack
    f = round(ff{i});
    xx = f(1,:);
    yy = f(2,:);
    zz = f(3,:);

    % clamp
    xx = max(1, min(nx, xx));
    yy = max(1, min(ny, yy));
    zz = max(1, min(nz, zz));
    
    % check
    ind = ((zz-1)*ny + (yy-1))*nx + xx;
    if ~any(A(ind)), continue, end
    if ~any(B(ind)), continue, end
%     if is_C && ~any(C(ind)), continue, end
%     if is_D && any(D_(ind)), continue, end

    cnt = cnt + 1;
    ff_{cnt} = ff{i};
  end
  
  % trim
  ff_ = ff_(1:cnt);
end
