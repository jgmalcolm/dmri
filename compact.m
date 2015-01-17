function v = compact(vals)
  vals_ = unique(vals);
  % adjust for negatives
  vals  = vals  + min(vals_) + 1;
  vals_ = vals_ + min(vals_) + 1;

  lut = zeros(1,max(vals_));
  lut(vals_) = 1:numel(vals_);

  v = lut(vals);
end
