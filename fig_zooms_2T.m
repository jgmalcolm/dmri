function fig_zooms_2T

  gcf_ = get(gcf, {'PaperSize' 'PaperPosition'});
  set(gcf, 'PaperSize',  [4 6], 'PaperPosition', [0 0 4 6])

  disp = false;

  b = 1000;

  fn = sprintf('matlab_2cross_b%d_zoom', b);
  [T u] = loadsome(fn, 'T', 'u');
  ff_kf = loadsome([fn '_2T'], 'ff');
  [F_kf M_kf] = loadsome([fn '_2T_all'], 'F_kf', 'M_kf');
  
  fn = sprintf('figs/tensor_TMI/zoom_2T_b%d', b);
  prnt = @(fn) print('-dpng', fn);

  % grab spatial positions
  ff_kf = map(@double, ff_kf);
  [ff_kf_ ind] = filter_crossing(ff_kf, T.is_cross);
  ff_kf_ = ff_kf_{1};
  ind = ind{1};
  xx  = ff_kf{1}(1:2,:);  % entire fiber
  xx_ = ff_kf_(1:2,:); % region of interest
  F_kf = F_kf(:,ind);
  M_kf = M_kf(:,:,ind);
  
  % run SH within ROI
  L = 8; lambda = 0.006; % Maxime
  [M_sh S_sh F_sh] = fiber_2sh(T.S, xx_, u, T.th, L, lambda);
  M_sh = reshape(M_sh{1}(3:end,:), 3, 2, []);
  F_sh = F_sh{1};
  
  % run LM within ROI
  run_t_synth
  [f_fn h_fn] = model_2tensor(u, b);
  th = pi * T.th / 180;
  x0 = [[-1 0 0]             1200 100 ...
        [-cos(th) sin(th) 0] 1200 100]';
  est = est_lm(x0, param.lm.lb, param.lm.ub, f_fn, h_fn);
  ff_lm = fiber_lm(T.S, xx_, est, param);
  ff_lm = ff_lm{1};
  for i = 1:size(ff_lm,2)
    X = ff_lm(:,i);
    [m1 l1 m2 l2] = state2tensor(X);
    f = tensor_odf([m1; l1],u,b) + tensor_odf([m2;l2],u,b);
    F_lm(:,i) = f / sum(f);
    M_lm(:,:,i) = [m1 m2];
  end
  
  %%-- display fiber with ROI
  clf, colormap jet
  if disp, sp(1,2,1), end
  ga = signal2ga(T.S);
  if ~disp
    ga = ga / max(ga(:));
    ga = uint8(200*ga(:,:,[1 1 1]));
  end
  imagesc(ga); axis image off;
  set(gca, 'XLim', [0 20], 'YLim', [10 60]+.5);
  hold on;
  ind = xx(1,:) > 15;
  plot(xx(2,ind), xx(1,ind), 'r', 'LineWidth', 1.5);
  plot([9 11 11 9 9], [38 38 32 32 38], 'b', 'LineWidth', 3);
  hold off;
  
  if ~disp, set(gca, 'Position', [0 0 1 1]); prnt([fn '_fiber']); end
  
  %%-- display ODFs within ROI
  h_sep = 1.5;
  fx = 10;

  if disp; sp(1,2,2); else; clf; colormap jet; end;
  hold on;
  plot(xx(2,:),           xx(1,:), 'r', 'LineWidth', 1.5);
  plot(xx(2,:) + h_sep,   xx(1,:), 'r', 'LineWidth', 1.5);
  plot(xx(2,:) + 2*h_sep, xx(1,:), 'r', 'LineWidth', 1.5);
  axis ij equal
  set(gca, 'XLim', [9 11+2*h_sep], 'YLim', [32.7 37.3]);
  
  for i = 1:size(F_kf,2)
    x = [xx_(:,i); 0];
    % SH
    f = F_sh(:,i);  m = M_sh(:,:,i);
    f = minmax(f) / 2.3;
    odf_axes(f, u, m, x, 'k');
    % LM
    f = F_lm(:,i);  m = M_lm(:,:,i);
    f = minmax(f) / 1.9;
    odf_axes(f, u, m, x + [0 h_sep 0]', 'k');
    % UKF
    f = F_kf(:,i);  m = M_kf(:,:,i);
    f = minmax(f) / 1.9;
    odf_axes(f, u, m, x + [0 2*h_sep 0]', 'k');
  end


%   set(gca, 'XTick', [10 11.5], ...
%            'XTickLabel', str2mat('SH', 'filtered'), ...
%            'YTick', [], ...
%            'FontSize', 25);
  set(gca, 'XTick', [10 11.5 13], ...
           'XTickLabel', str2mat('SH', 'LS', 'filtered'), ...
           'YTick', [], ...
           'FontSize', 25);


  if ~disp
    set(gca, 'Position', [0 .07 1 .95]);
    prnt([fn '_zoom_LM']);
  end
  
  set(gcf, 'PaperSize', gcf_{1}, 'PaperPosition', gcf_{2});
end
