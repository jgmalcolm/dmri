function ijk2tube(ff, name, varargin)
  paths
  % drop fibers with less than two points (can't form tube)
  keep = cellfun(@(f) size(f,2) >= 2, ff);
  ff = ff(keep);
  if isempty(ff), return, end
  
  p = myparams([], varargin);
  
  % generate poly-model
  fn = tempname;
  if size(ff{1},1) > 3,  ff = map(@(x)x(1:3,:), ff); end
  ijk2vtk(ff, fn, varargin{:});
  
  % convert to tube-model
  try sides = p.sides;   catch sides = 6;    end
  try radius = p.radius; catch radius = 0.3; end
  cmd = '~malcolm/src/tcl/lines2tubes.tcl %s.vtk %s.vtk %d %.1f; rm %s.vtk';
  cmd = sprintf(cmd, fn, name, sides, radius, fn);
  system(cmd);
end
