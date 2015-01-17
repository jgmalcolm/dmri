function [xx vv] = fibers2exemplars(xx, cc)
  xx = xx(unique(cc));
  
  vv = cell(size(xx));
  for i = 1:numel(vv)
    vv{i} = i(ones(1,size(xx{i},2)));
  end
end
