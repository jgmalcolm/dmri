function seeds = div_seeds(seeds, div, ndiv)
% I have no clue what I did here...but it works
  assert(div <= ndiv);
  ind = find(seeds);
  seeds = false(size(seeds));

  span = ceil(numel(ind) / ndiv);
  if div*span > numel(ind)
    span = span - (div*span - numel(ind));
    if span < 1,  warning('no seeds'), end
  end
  ind = ind(span*(div-1) + (1:span));

  seeds(ind) = true;
end
