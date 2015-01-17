function [fin fout] = inside(fibers, M)
% filter out fibers: those completely inside, those going outside
  
  n = numel(fibers);
  [fin fout] = deal(cell(1,n));
  in_cnt = 0; out_cnt = 0;
  
  [nx ny nz] = size(M);

  for i = 1:n
    f = round(fibers{i});
    xx = f(1,:);
    yy = f(2,:);
    zz = f(3,:);

    % clamp
    xx(xx <  1) = 1;  yy(yy <  1) = 1;  zz(zz <  1) = 1;
    xx(xx > nx) = nx; yy(yy > ny) = ny; zz(zz > nz) = nz;
    
    % check
    m = M(((zz-1)*ny + (yy-1))*nx + xx);
    if all(m)
      in_cnt = in_cnt + 1;
      fin{in_cnt} = fibers{i};
    else
      out_cnt = out_cnt + 1;
      fout{out_cnt} = fibers{i};
    end
  end
  
  % trim
  fin  =  fin(1: in_cnt);
  fout = fout(1:out_cnt);
end
