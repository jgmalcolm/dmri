function trim_corridor_cc_small3(dir, mask)
  min_len = 100;

  % gather and connect fibers
  disp('reading...');
  [f1 f1_] = loadsome([dir '/f_1'], 'f', 'f_');
  [f2 f2_] = loadsome([dir '/f_2'], 'f', 'f_');
   f3      = loadsome([dir '/f_3'], 'f');
  disp('connecting...');
  F2 = fiber_connect(f1, f1_, f2);
  F3 = fiber_connect(F2, f2_, f3);
  N = numel(f1) + numel(f2) + numel(f3);

  fprintf('dropping small fibers...');
  f1 = {f1{cellfun(@(x)size(x,2) > min_len, f1)}};
  f2 = {f2{cellfun(@(x)size(x,2) > min_len, F2)}};
  f3 = {f3{cellfun(@(x)size(x,2) > min_len, F3)}};
  n = numel(ff);
  ff = {f1{:} f2{:} f3{:}};
  fprintf('(%.0f%%)\n', 100*(N - n)/N);


  [nx ny nz] = size(mask);
  [xx yy zz] = ndgrid(1:nx, 1:ny, 1:nz);

  % select fibers that "qualify" as trans-callosum
  disp('separating...');
  mask_ = abs(xx - nx/2) < 15;
  [fcc fcc_] = inside(ff, mask_);

  fprintf('saving...(before %d, now %d)\n', N, n);
  save([dir '/cc'], 'fcc', 'fcc_');
  disp('converting callosal radiata to tubes...');
  ijk2tube(fcc,  [dir '/cc' ], 'sides', 3);
  disp('converting transcallosal to tubes...');
  ijk2tube(fcc_, [dir '/cc_'], 'sides', 3);
end
