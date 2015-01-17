clf;
disp = true;

th = 15:5:90;
W  = .5:.1:.8;

for b = [1000]
  fn = sprintf('matlab_2cross_w_b%d_2TW_mse', b);
  [mse_kf mse_pp mse_sh] = loadsome(fn, 'mse_kf', 'mse_pp', 'mse_sh');

  mu_kf = cellfun(@mean, mse_kf); sd_kf = cellfun(@std, mse_kf);
  mu_pp = cellfun(@mean, mse_pp); sd_pp = cellfun(@std, mse_pp);
  mu_sh = cellfun(@mean, mse_sh); sd_sh = cellfun(@std, mse_sh);

  sigma = 1;

  i = 1;
  for w = W
    if disp, sp(4,2,2*(i-1)+1), else clf, end
    set(gca, 'NextPlot', 'add');
    plot(th([1 end]), w([1 1]), 'y', 'LineWidth', 4);
    
    plot_int(th, mu_pp(i,:,1), sd_pp(i,:,1), 'b');
    plot_int(th, mu_sh(i,:,1), sd_sh(i,:,1), 'r');
    plot_int(th, mu_kf(i,:,1), sd_kf(i,:,1), 'm');
    fig_mse_post(th, disp)
    i = i + 1;
  end % w
  
  i = 1;
  for w = W
    if disp, sp(4,2,2*i), else clf, end
    set(gca, 'NextPlot', 'add');
    plot(th([1 end]), w([1 1]), 'y', 'LineWidth', 4);

    plot_int(th, mu_pp(i,:,2), sd_pp(i,:,2), 'b');
    plot_int(th, mu_sh(i,:,2), sd_sh(i,:,2), 'r');
    plot_int(th, mu_kf(i,:,2), sd_kf(i,:,2), 'm');
    fig_mse_post(th, disp)
    i = i + 1;
  end % w

end
