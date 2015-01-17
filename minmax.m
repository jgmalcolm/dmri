function f = minmax(f)
  f = (f - min(f(:)))/range(f(:));
end
