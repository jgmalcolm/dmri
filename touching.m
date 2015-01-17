function ff_ = touching(ff, A, B)
% filter out fibers touching (A) but not touching (B)
  
  n = numel(ff);
  ff_ = cell(1,n);
  ff_cnt = 0;

  [nx ny nz] = size(A);

  has_B = (nargin == 3);

  for i = 1:n
    % unpack
    f = ff{i};
    xx = round(f(1,:));
    yy = round(f(2,:));
    zz = round(f(3,:));

    % clamp
    xx(xx <  1) = 1;  yy(yy <  1) = 1;  zz(zz <  1) = 1;
    xx(xx > nx) = nx; yy(yy > ny) = ny; zz(zz > nz) = nz;
    
    % check
    ind = ((zz-1)*ny + (yy-1))*nx + xx;
    is_A = any(A(ind));
    
    if has_B
      is_B = any(B(ind));
      is_A = is_A && ~is_B;
    end

    if is_A
      ff_cnt = ff_cnt + 1;
      ff_{ff_cnt} = f;
    end
  end
  
  % trim
  ff_ = ff_(1:ff_cnt);
end
