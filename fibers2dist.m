function D = fibers2dist(xx)
  n = numel(xx);
  D = zeros(n,'single');

  for c = 1:n
    x = xx{c};
    for r = 1:n
      D(r,c) = mean(dcp(xx{r}, x));
    end
  end
end
