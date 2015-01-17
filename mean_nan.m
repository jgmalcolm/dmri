function y = mean_nan(x)
% assumes first dimension
  [m n] = size(x);
  y = zeros(m,1);
  for i = 1:m
    x_ = x(i,:);
    y(i) = sum(x_(isfinite(x_)))/n;
  end
end
