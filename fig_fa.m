th = 0:5:90;
l2  = 100:50:900;

disp = false;

prnt = @(fn) print('-dpng', '-r100', fn);

for b = [1000]
  fn = sprintf('matlab_2cross_fa_b%d_2T_e', b);
  [e_kf e_1t] = loadsome(fn, 'e_kf', 'e_1t');
  
  mu_kf = cellfun(@(e) mean(e(1,~isinf(e))), e_kf);
  sd_kf = cellfun(@(e) std(e(1,~isinf(e))),  e_kf);
  mu_1t = cellfun(@(e) mean(e(~isinf(e))), e_1t);
  sd_1t = cellfun(@(e) std(e(~isinf(e))),  e_1t);

  clf
  
  fn = sprintf('figs/miccai_study/fa_2T_b%d', b);
  
  %%-- FA versus THETA
  if disp, sp(2,2,1), else clf, end
  set(gca, 'NextPlot', 'add');
  fa1 = l2fa([1200 100]);
  plot(th([1 end]), fa1([1 1]), 'k--', 'LineWidth', 4);
  ind = 1:19;
  plot_int(th, mu_1t(ind), sd_1t(ind), 'b');
  plot_int(th, mu_kf(ind), sd_kf(ind), 'r');
  set(gca, 'XLim', [-1 90.5], 'XTick', 0:15:90)
  if ~disp, set(gca, 'FontSize', 25); end
  set(gca, 'YLim', [.2 1], 'YTick', .2:.2:1, 'YGrid', 'on', ...
           'YTickLabel', str2mat('0.2','0.4','0.6','0.8','1.0'));
  if ~disp, xlabel('crossing angle (ground truth)'); end
  if ~disp, ylabel('estimated FA'); end
  if ~disp, prnt([fn '_theta']); end


  %%-- FA versus 0 degrees
  if disp, sp(2,2,2), else clf, end
  set(gca, 'NextPlot', 'add');
  fa2 = l2fa([1200 l2(end)]);
  plot(l2([1 end]), [fa1 fa2], 'k--', 'LineWidth', 4);
  ind = 20:32;
  plot_int(l2(1:end-4), mu_1t(ind), sd_1t(ind), 'b');
  plot_int(l2(1:end-4), mu_kf(ind), sd_kf(ind), 'r');
  set(gca, 'XLim', [80 720], 'XTick', 100:200:700)
  if ~disp, set(gca, 'FontSize', 25); end
  set(gca, 'YLim', [.2 1], 'YTick', .2:.2:1, 'YGrid', 'on', ...
           'YTickLabel', str2mat('0.2','0.4','0.6','0.8','1.0'));
  if ~disp, xlabel('\lambda_2 (ground truth)'); end
  if ~disp, ylabel('estimated FA'); end
  if ~disp, prnt([fn '_theta_00']); end

  %%-- FA versus 45 degrees
  if disp, sp(2,2,3), else clf, end
  set(gca, 'NextPlot', 'add');
  fa2 = l2fa([1200 l2(end)]);
  plot(l2([1 end]), [fa1 fa2], 'k--', 'LineWidth', 4);
  ind = 37:49;
  plot_int(l2(1:end-4), mu_1t(ind), sd_1t(ind), 'b');
  plot_int(l2(1:end-4), mu_kf(ind), sd_kf(ind), 'r');
  set(gca, 'XLim', [80 720], 'XTick', 100:200:700)
  if ~disp, set(gca, 'FontSize', 25); end
  set(gca, 'YLim', [.2 1], 'YTick', .2:.2:1, 'YGrid', 'on', ...
           'YTickLabel', str2mat('0.2','0.4','0.6','0.8','1.0'));
  if ~disp, xlabel('\lambda_2 (ground truth)'); end
  if ~disp, ylabel('estimated FA'); end
  if ~disp, prnt([fn '_theta_45']); end

  %%-- FA versus 90 degrees
  if disp, sp(2,2,4), else clf, end
  set(gca, 'NextPlot', 'add');
  fa2 = l2fa([1200 l2(end)]);
  plot(l2([1 end]), [fa1 fa2], 'k--', 'LineWidth', 4);
  ind = 54:66;
  plot_int(l2(1:end-4), mu_1t(ind), sd_1t(ind), 'b');
  plot_int(l2(1:end-4), mu_kf(ind), sd_kf(ind), 'r');
  set(gca, 'XLim', [80 720], 'XTick', 100:200:700)
  if ~disp, set(gca, 'FontSize', 25); end
  set(gca, 'YLim', [.2 1], 'YTick', .2:.2:1, 'YGrid', 'on', ...
           'YTickLabel', str2mat('0.2','0.4','0.6','0.8','1.0'));
  if ~disp, xlabel('\lambda_2 (ground truth)'); end
  if ~disp, ylabel('estimated FA'); end
  if ~disp, prnt([fn '_theta_90']); end

end
