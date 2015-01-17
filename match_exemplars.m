function [xx vx yy vy] = match_exemplars(xx, cx, yy, cy)
  
  % assume xx has more exemplars so we base coloring on xx
  if numel(yy) > numel(xx)
    [xx vx yy vy] = match_exemplars(yy, cy, xx, cx);
    return
  end

  [xx vx] = fibers2exemplars(xx, cx);
  [yy vy] = fibers2exemplars(yy, cy);
  
  D = e2e(xx, yy);
  [dd ii] = min(D);
  numel(unique(ii))
  
  for i = 1:numel(yy)
    vy{i}(:) = ii(i);
  end
end



function D = e2e(xx,yy)
  nx = numel(xx);
  ny = numel(yy);
  D = zeros(nx,ny,'single');

  for c = 1:ny
    y = yy{c};
    for r = 1:nx
      D(r,c) = mean(dcp(y, xx{r}));
    end
  end
end
