function fibers_ = through(fibers, A, B, C)
% filter out fibers touching both (A,B) and passing through (C)
  
  n = numel(fibers);
  fibers_ = cell(1,n);
  fibers_cnt = 0;

  [nx ny nz] = size(A);

  for i = 1:n
    % unpack
    f = round(fibers{i});
    xx = f(1,:);
    yy = f(2,:);
    zz = f(3,:);

    % clamp
    xx(xx <  1) = 1;  yy(yy <  1) = 1;  zz(zz <  1) = 1;
    xx(xx > nx) = nx; yy(yy > ny) = ny; zz(zz > nz) = nz;
    
    % check
    ind = ((zz-1)*ny + (yy-1))*nx + xx;
    is_A = any(A(ind));
    is_B = any(B(ind));

    if is_A && is_B
      fibers_cnt = fibers_cnt + 1;
      fibers_{fibers_cnt} = fibers{i};
    end
  end
  
  % trim
  fibers_ = fibers_(1:fibers_cnt);
end
