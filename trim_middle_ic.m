function trim_middle_ic(base, varargin)
  min_len = 40;
  
  p = myparams([], varargin);
  
  try p.sides; catch p.sides = 3; end
  %try p.frame; catch p.frame = @ReadNrrdHeader; end
  try p.frame; catch p.frame = @nrrdHeader_AG; end

  % gather and connect fibers
  disp('reading...');
%   [f1 f1_] = loadsome([base '_1'], 'f', 'f_');
%   [f2 f2_] = loadsome([base '_2'], 'f', 'f_');
%    f3      = loadsome([base '_3'], 'f');
%   n = numel(f1) + numel(f2) + numel(f3);
%   fprintf('connecting %d...\n', n);
%   F2 = fiber_connect(f1, f1_, f2);
%   F3 = fiber_connect(F2, f2_, f3);
%   ff = {f1{:} F2{:} F3{:}};

  [f1 f1_] = loadsome([base '_1'], 'f', 'f_');
   f2      = loadsome([base '_2'], 'f');
  n = numel(f1) + numel(f2);
  fprintf('connecting %d...\n', n);
  F2 = fiber_connect(f1, f1_, f2);
  ff = {f1{:} F2{:}};

%   ff = loadsome([base '_1'], 'f');
  ff = {ff{~cellfun(@isempty,ff)}};
  n = numel(ff);
  
  if isfield(p, 'mask')
    n_ = n;
    fprintf('dropping outside corridor...');
    [nx ny nz] = size(p.mask);
    [xx yy zz] = ndgrid(1:nx, 1:ny, 1:nz);
    mask_corridor = p.mask & 125 <= yy & yy <= 156;
    ff = inside(ff, mask_corridor);
    n = numel(ff);
    fprintf('(%.0f%%)\n', 100*(n_ - n)/n_);
  end
  
  fprintf('dropping non-motor fibers...');
  ff = {ff{cellfun(@is_ending, ff)}};
  n_ = n; n = numel(ff);
  fprintf('(%.0f%%)\n', 100*(n_ - n)/n_);

  if isfield(p, 'mask_cc')
    fprintf('dropping CC fibers...');
    ff = {ff{~cellfun(@is_touching, ff)}};
    n_ = n; n = numel(ff);
    fprintf('(%.0f%%)\n', 100*(n_ - n)/n_);
  end

  fprintf('dropping small fibers...');
  ff = {ff{cellfun(@(x)size(x,2) > min_len, ff)}};
  n_ = n; n = numel(ff);
  fprintf('(%.0f%%)\n', 100*(n_ - n)/n_);
  
  fprintf('saving %d...\n', n);
  save([base '_ic'], 'ff');
  disp('tubifurcation...');
  ijk2tube(ff,  [base '_ic' ], 'sides', p.sides, 'frame', p.frame);

  function r = is_touching(f)
    if isempty(f), r = true; return, end
    xx = round(f(1:3,:));
    if any(xx(1,:) == 0 | xx(1,:) == 256 | ...
           xx(2,:) == 0 | xx(2,:) == 256 | ...
           xx(3,:) == 0 | xx(3,:) == 45)
      r = true;
      return
    end
    ind = sub2ind(size(p.mask_cc), xx(1,:), xx(2,:), xx(3,:));
    r = any(p.mask_cc(ind));
  end
  
  function r = is_ending(f)
    if isempty(f), r = false; return, end
    r = size(f,2) > 5 && any(f(3,end-4:end) < 26);
  end
end
