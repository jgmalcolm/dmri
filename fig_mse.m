function fig_mse
  clf;
  disp = false;

  lt = .75*[1 1 1];
  dk = .50*[1 1 1];

  th = 15:5:90;
  i = 1;
  for b = [1000 3000]
    fn = sprintf('matlab_2cross_b%d_2T_mse', b);
    [mse_kf mse_pp mse_sh] = loadsome(fn, 'mse_kf', 'mse_pp', 'mse_sh');

    mu_kf = cellfun(@mean, mse_kf); sd_kf = cellfun(@std, mse_kf);
    mu_pp = cellfun(@mean, mse_pp); sd_pp = cellfun(@std, mse_pp);
    mu_sh = cellfun(@mean, mse_sh); sd_sh = cellfun(@std, mse_sh);
    
    fn = sprintf('figs/tensor_NI/bw/mse_2T_b%d', b);

    if disp, sp(2,2,i); i = i + 1; else clf; end
    set(gca, 'NextPlot', 'add');
    plot_int(th, mu_pp(1,:), sd_pp(1,:), lt);
    plot_int(th, mu_sh(1,:), sd_sh(1,:), dk);
    plot_int(th, mu_kf(1,:), sd_kf(1,:), 'k');
    fig_mse_post(th, disp)
    if ~disp, print('-dpng', '-r100', [fn '_clean']); end
    
    if disp, sp(2,2,i); i = i + 1; else clf; end
    set(gca, 'NextPlot', 'add');
    plot_int(th, mu_pp(2,:), sd_pp(2,:), lt);
    plot_int(th, mu_sh(2,:), sd_sh(2,:), dk);
    plot_int(th, mu_kf(2,:), sd_kf(2,:), 'k');
    fig_mse_post(th, disp)
    if ~disp, print('-dpng', '-r100', [fn '_dirty']); end
  end
end


function fig_mse_post(th, disp)
  set(gca, 'XLim', [14 90.5], 'XTick', th(1:3:end));
  set(gca, 'YLim', [0 .008],  'YTick', 0:.002:.008, ...
           'YTickLabel', str2mat('0.000', '0.002', '0.004', ...
                                 '0.006', '0.008'), ...
           'YGrid', 'on');
  if disp, return, end
  set(gca, 'FontSize', 25);
  xlabel('crossing angle (ground truth)');
  ylabel('MSE of reconstructed signal');
end
