function trim_corridor_cc(ff, dir, mask)

  [nx ny nz] = size(mask);
  [xx yy zz] = ndgrid(1:nx, 1:ny, 1:nz);

  % select fibers that "qualify" as trans-callosum
  disp('separating...');
  mask_ = abs(xx - nx/2) < 15;
  [fcc fcc_] = inside(ff, mask_);

  fprintf('converting callosal radiata to tubes (%d)...\n', numel(fcc));
  ijk2tube(fcc,  [dir '/cc' ]);
  fprintf('converting transcallosal to tubes (%d)...\n', numel(fcc_));
  ijk2tube(fcc_, [dir '/cc_']);
  disp('saving...');
  save([dir '/cc'], 'fcc', 'fcc_');
end
