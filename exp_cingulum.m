% ff = exp_cingulum(ff, mask_cing_jm, mask_cing == 1);
function ff_ = exp_cingulum(ff, A, B)
  id = unique(A)';
  id = id(id > 0);
  
  n = numel(ff);
  ff_ = cell(1,n);
  ff_cnt = 0;

  [nx ny nz] = size(A);

  for i = 1:n
    % unpack
    f = round(ff{i});
    xx = f(1,:);
    yy = f(2,:);
    zz = f(3,:);

    % clamp
    xx = max(1, min(nx, xx));
    yy = max(1, min(nx, yy));
    zz = max(1, min(nx, zz));
    
    % check
    ind = ((zz-1)*ny + (yy-1))*nx + xx;
    if any(B(ind)), continue, end

    a = A(ind);
    na = 0;
    for j = id
      na = na + any(a == j);
    end

    if na >= 2
      ff_cnt = ff_cnt + 1;
      ff_{ff_cnt} = ff{i};
    end
  end
  
  % trim
  ff_ = ff_(1:ff_cnt);
end
