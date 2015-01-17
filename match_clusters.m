function [xx vx yy vy] = clusters(xx, cx, yy, cy)
  
  % assume xx has more exemplars so we base coloring on xx
  if numel(unique(cy)) > numel(unique(cx))
    [xx vx yy vy] = clusters(yy, cy, xx, cx);
    return
  end
  
  ex = fibers2exemplars(xx, cx);
  ey = fibers2exemplars(yy, cy);
  D = e2e(ex, ey);
  [dd ii] = min(D);
  
  vx = fibers2clusters(xx, cx);
  vy = fibers2clusters(yy, cy);

  for i = 1:numel(vy)
    v = vy{i}(1);
    vy{i}(:) = ii(v);
  end
end



function D = e2e(xx,yy)
  nx = numel(xx);
  ny = numel(yy);
  D = zeros(nx,ny);

  for c = 1:ny
    y = yy{c};
    for r = 1:nx
      D(r,c) = mean(dcp(y, xx{r})); % correct?
    end
  end
end
