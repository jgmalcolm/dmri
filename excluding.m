function fibers_ = excluding(fibers, A, B, C)
% filter out fibers connecting (A,B) but not touching (C)
  
  n = numel(fibers);
  fibers_ = cell(1,n);
  fibers_cnt = 0;

  [nx ny nz] = size(A);

  for i = 1:n
    % unpack
    f = fibers{i};
    xx = round(f(1,:));
    yy = round(f(2,:));
    zz = round(f(3,:));

    % clamp
    xx(xx <  1) = 1;  yy(yy <  1) = 1;  zz(zz <  1) = 1;
    xx(xx > nx) = nx; yy(yy > ny) = ny; zz(zz > nz) = nz;
    
    % check
    ind = ((zz-1)*ny + (yy-1))*nx + xx;
%     is_A = any(A(ind));
%     is_B = any(B(ind));

    % IOFF
    is_A = nnz(A(ind)); is_A = is_A && is_A <= 3; % no looping back
    is_B = nnz(B(ind)); is_B = is_B && is_B <= 3;
    is_C = any(C(ind));

    if is_A && is_B && ~is_C
      fibers_cnt = fibers_cnt + 1;
      fibers_{fibers_cnt} = f;
    end
  end
  
  % trim
  fibers_ = fibers_(1:fibers_cnt);
end
