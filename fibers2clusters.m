function [vv lut] = fibers2clusters(xx, cc)
  lut = ones(size(cc));
  cc_ = unique(cc);
  lut(cc_) = 1:numel(cc_);
  lut(:) = lut(cc);
  
  vv = cell(size(xx));
  for i = 1:numel(xx)
    vv{i} = lut(i,ones(1,size(xx{i},2)));
  end
end
