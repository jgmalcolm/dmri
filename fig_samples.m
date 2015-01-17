
%- every 20 degrees
% dx = .8;
% dy = 2.4;
% th = 30:20:90;
% ii = 6:4:18;

colormap gray


for b = [1000 3000]

  fn = sprintf('matlab_2cross_b%d', b);
  [tract u] = loadsome(fn, 'tract', 'u');
  [S_clean F_clean] = loadsome([fn '_clean'], 'S_clean', 'F_clean');

  fn = sprintf('figs/tensor_NI/bw/samples_b%d', b);

  T = tract(:,10);
  S = S_clean(:,10);
  F = F_clean(:,10);

  s_pure  = flat(S{1}(35,10,:));   s_pure  = s_pure  / norm(s_pure);
  f_pure  = flat(F{1}(35,10,:));   f_pure  = minmax(f_pure);%  / sum(f_pure);
  s_clean = flat(T(1).S(35,10,:)); s_clean = s_clean / norm(s_clean);
  s_dirty = flat(T(2).S(35,10,:)); s_dirty = s_dirty / norm(s_dirty);
  m = squeeze(T(1).M(35,10,:,:)) / 12;

  clf;
  sp(2,2,1); odf(s_pure ,u); odf_axes(m);    axis image off ij; view(2)
  sp(2,2,2); odf(f_pure ,u); odf_axes(12*m); axis image off ij; view(2)
  sp(2,2,3); odf(s_pure ,u); odf_axes(m);    axis image off ij; view(3)
  sp(2,2,4); odf(f_pure ,u); odf_axes(12*m); axis image off ij; view(3)
  print('-dpng', '-r70', [fn '_pure']);
  
  clf;
  sp(2,2,1); odf(s_clean,u); odf_axes(m);    axis image off ij; view(2)
  sp(2,2,2); odf(s_dirty,u); odf_axes(m);    axis image off ij; view(2)
  sp(2,2,3); odf(s_dirty,u); odf_axes(m);    axis image off ij; view(3)
  sp(2,2,4); odf(s_clean,u); odf_axes(m);    axis image off ij; view(3)

  print('-dpng', '-r70', [fn '_noisy']);
end
