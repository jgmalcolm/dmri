function trim_corridor_tc(base, mask)
  % gather and connect fibers
  disp('reading...');
  [f1 f1_] = loadsome([base '_1'], 'f', 'f_');
  [f2 f2_] = loadsome([base '_2'], 'f', 'f_');
   f3      = loadsome([base '_3'], 'f');
   f2 = fiber_connect(f1, f1_, f2);
   f3 = fiber_connect(f2, f2_, f3);
%   ff = {};
%   for i = 1:3
%     fn = sprintf('%s_%d.mat', base, i);
%     if ~exist(fn), break, end
%     f = loadsome(fn, 'f');
%     ff = {ff{:} f{:}};
%   end
  ff = {f1{:} f2{:} f3{:}};
  ff = {ff{~cellfun(@isempty, ff)}};
  ff = {ff{cellfun(@(x) size(x,2) >= 10, ff)}};

  [nx ny nz] = size(mask);
  [xx yy zz] = ndgrid(1:nx, 1:ny, 1:nz);

  % select fibers within few slices
  mask_corridor = mask & 63 <= yy & yy <= 75;
  ff = inside(ff, mask_corridor);

%   ijk2tube(ff, [base '_all'], 'sides', 3);
%   return

  % select fibers that "qualify" as trans-callosum
  disp('separating...');
  mask_ = abs(xx - nx/2) < 13 & zz <= 32;
  [ftc ftc_] = inside(ff, mask_);
  
  disp('saving...');
  save([base '_tc'], 'ftc', 'ftc_');
  disp('converting callosal radiata to tubes...');
  ijk2tube(ftc,  [base '_tc' ], 'sides', 3);
  disp('converting transcallosal to tubes...');
  ijk2tube(ftc_, [base '_tc_'], 'sides', 3);
  
end
