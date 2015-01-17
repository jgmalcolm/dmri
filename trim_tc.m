function trim_tc(dir, id, mask)
  % gather and connect fibers
%   [f1 f1_] = loadsome([dir '/f_1'], 'f', 'f_');
%   [f2 f2_] = loadsome([dir '/f_2'], 'f', 'f_');
%    f3      = loadsome([dir '/f_3'], 'f');
%    f2 = fiber_connect(f1, f1_, f2);
%    f3 = fiber_connect(f2, f2_, f3);
  disp('reading...');
  for i = 1:4
    fn = sprintf('%s/%s_%d.mat', dir, id, i);
    if ~exist(fn), break, end
    ff{i} = loadsome(fn, 'ff');
  end
  ff = empty([ff{:}]);

  [nx ny nz] = size(mask);
  [xx yy zz] = ndgrid(1:nx, 1:ny, 1:nz);

  % select fibers within few slices
  %mask_corridor = mask & 63 <= yy & yy <= 75;
  mask_corridor = mask & 63 <= yy & yy <= 77; % LM
  ff = inside(ff, mask_corridor);

  % select fibers that "qualify" as trans-callosum
  disp('separating...');
  mask_ = abs(xx - nx/2) < 13 & zz <= 32;
  [ftc ftc_] = inside(ff, mask_);
  
  fn = sprintf('%s/%s_tc', dir, id);
  save(fn, 'ftc', 'ftc_');
  fprintf('converting callosal radiata to tubes (%d)...\n', numel(ftc));
  ijk2tube(ftc,  fn);

  fn = sprintf('%s/%s_tc_', dir, id);
  fprintf('converting transcallosal to tubes (%d)...\n', numel(ftc_));
  ijk2tube(ftc_, fn);
end
