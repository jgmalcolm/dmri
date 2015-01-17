function fig_watson(u)
  disp = true;

  if ~nargin
    u = icosahedron(5);
  end
  
  m = [1 -1 1]';

  k_strong = watson(u, [m; 2.00]);
  k_weak   = watson(u, [m; 0.50]);
  k_iso    = watson(u, [m; 0.01]);
  
  prnt = @(suff) print('-dpng', '-r70', ['figs/watson_' suff]);
  
  function fx
    axis image off;
    if ~disp
      set(gca, 'Position', [0 0 1 1]);
    end
  end

  clf
  if disp, sp(2,3,1); end
  odf_axes(k_strong, u, m); fx
  if disp, sp(2,3,2); else prnt('strong'), clf; end
  odf_axes(k_weak,   u, m); fx
  if disp, sp(2,3,3); else prnt('weak'), clf; end
  odf_axes(k_iso,    u, m); fx
  if ~disp, prnt('iso'), clf; end
  
  a = pi/2*.4;
  m(:,2) = [cos(a) sin(a) 0]';
  a = pi/2*.24;
  m(:,3) = [cos(a) 0 sin(a)]';
  m = gramschmidt(m);

  k_2 = model_2watson_h([m(:,1); 3; m(:,2); 3], u);
  k_3 = model_3watson_h([m(:,1); 3; m(:,2); 3; m(:,3); 3], u);
  
  if disp, sp(2,2,3); end
  odf_axes(k_2, u, m(:,1:2)); fx
  if disp, sp(2,2,4); else prnt('two'), clf; end
  odf_axes(k_3, u, m); fx
  if ~disp, prnt('three'); end

end
