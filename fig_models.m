function fig_models
  
  mm = 2;

  disp = false;

  b = 1000;

  fn = sprintf('matlab_2X_b%d', b);
  [tract u] = loadsome(fn, 'tract', 'u');
  [f_kf param] = loadsome([fn '_2T_KF'], 'fibers_kf', 'param');
  
  % select field
  T = tract(3);
  f_kf = f_kf{3}{1};

  fn = sprintf('figs/tensor_NI/models_b%d', b);
  prnt = @(fn) print('-dpng', '-r200', fn);

  % grab spatial positions
  [f_kf_ ind] = filter_crossing({f_kf}, T.is_cross);
  f_kf_ = f_kf_{1}; ind = ind{1};
  xx  = f_kf(1:2,:);  % entire fiber
  xx_ = f_kf_(1:2,:); % region of interest
  
  % run SH within ROI
  L = 8; lambda = 0.006; % Maxime
  [M_sh S_sh F_sh] = fiber_2sh_m(T.S, xx_, u, T.th, L, lambda);
  M_sh = reshape(M_sh{1}(3:end,:), 3, 2, []);
  F_sh = F_sh{1};
  u_sh = icosampling(2);
  
  % grab ROI ODFs  for 1T and 2T
  m = size(xx_,2);
  for i = 1:m
    [x X] = deal(f_kf_(1:2,i), f_kf_(3:end,i));
    SS(:,i) = interp2exp(T.S, x);
    %% 1T
    D = direct_1T(u, b, SS(:,i));
    F = sqrt((pi*b)./sum((u * inv(D)) .* u, 2));
    F_1t(:,i) = F / sum(F);  % unit mass
    [V U] = svd(D);
    M_1t(:,1,i) = U(1)*V(:,1); % principle eigenvector

    %% 2T
    [m1 l1 m2 l2] = state2tensor(X);
    F1 = tensor_odf([m1; l1], u, b);
    F2 = tensor_odf([m2; l2], u, b);
    F_kf(:,i) = F1 + F2;
    M_kf(:,:,i) = [m1 m2];
  end
  
  
  %%-- display signal
  clf, colormap jet
  if disp, sp(1,2,1), end
  fcs = convhulln(u);
  for i = mm
    x = [xx_(:,i); 0];
    odf(SS(:,i), u, fcs, x);
  end
  axis image off ij; view(2)
  if ~disp, prnt([fn '_signal']); end
  
  %%-- display ODFs within ROI
  h_sep = 1.5;
  fx = 10;

  % SH
  model(disp, 1, 'SH')
  f = F_sh(:,mm);  M = M_sh(:,:,mm);
  f = minmax(f) / 2.3;
  odf_axes(f, u_sh, M);
  if ~disp, prnt([fn '_SH']); end

  % 1T
  model(disp, 2, '1T')
  f = F_1t(:,mm);  M = M_1t(:,1,mm);
  f = minmax(f) / 1.9;
  odf_axes(f, u, M);
  if ~disp, prnt([fn '_1T']); end

  % 2T
  model(disp, 3, '2T')
  f = F_kf(:,mm);  M = M_kf(:,:,mm);
  f = minmax(f) / 1.9;
  odf_axes(f, u, M);
  if ~disp, prnt([fn '_2T']); end
end


function model(disp, i, name)
  if disp, sp(3,2,2*(i-1)+2); else clf; end
  axis ij equal
  box off
  set(gca, 'FontSize', 18, 'XTick', [], 'YTick', []);
  xlabel(name);
end
