function [fibers indices] = filter_crossing(fibers, is_cross)
  
  param.valid = 1;
  
  indices = fibers;

  % grab crossing region
  for i = 1:numel(fibers)
    f = fibers{i};
    if isempty(f), continue, end
    keep = is_crossing(f(1:2,:), is_cross, param);
    fibers{i}  = f(:,keep);
    indices{i} = keep;
  end
end
  
function r = is_crossing(x, is_cross, param)
  r = false(1,size(x,2));
  for i = 1:numel(r)
    r(i) = interp2scalar(is_cross, x(:,i)) > param.valid;
  end
end
