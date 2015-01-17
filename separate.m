function [fin fout] = separate(fibers, M)
% filter out fibers: those completely inside, those going outside
  
  n = numel(fibers);
  [fin fout] = deal(cell(1,n));
  
  [nx ny nz] = size(M);

  for i = 1:n
    f = round(fibers{i});
    xx = f(1,:);
    yy = f(2,:);
    zz = f(3,:);

    % clamp
    xx(xx <  1) = 1;  yy(yy <  1) = 1;  zz(zz <  1) = 1;
    xx(xx > nx) = nx; yy(yy > ny) = ny; zz(zz > nz) = nz;
    
    % separate
    m = M(((zz-1)*ny + (yy-1))*nx + xx);
    f = fibers{i};
    fin{i}  = f(:,m);
    fout{i} = f(:,~m);
  end
end
