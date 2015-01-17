function ff = fibers2cortical(fn, isL, isR, n)

  for i = 1:2
    [f{i} f_{i}] = loadsome([fn int2str(i)], 'f', 'f_');
  end
  f2 = fiber_connect(f{1}, f_{1}, f{2});
  ff = {f{1}{:} f2{:}};
  
  if n == 3
    [f{3} f_{3}] = loadsome([fn '3'], 'f', 'f_');
    f3 = fiber_connect(f2, f_{2}, f{3});
    ff = {ff{:} f3{:}};
  else
  end
  
  isL = close_mask(isL, 10);
  isR = close_mask(isR, 10);
  ff = connecting(ff, isL, isR);
end
