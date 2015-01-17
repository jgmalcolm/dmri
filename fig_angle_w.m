function fig_angle_w
  th = 0:5:90;
  W  = [.5 .6 .7];
  m = numel(W);

  disp = false;

  prnt = @(fn) print('-dpng', '-r70', fn);

  for b = 1000
    fn = sprintf('matlab_2cross_w_b%d_2T_e', b);
    [e_kf e_sh e_lm] = loadsome(fn, 'e_kf', 'e_sh', 'e_lm');
    
    [mu_kf sd_kf] = stats(e_kf);
    [mu_sh sd_sh] = stats(e_sh);
    [mu_lm sd_lm] = stats(e_lm);

    fn = sprintf('figs/tensor_TMI/angle_w_2T_b%d', b);

    clf
    
    ind = {13:19  13:19  14:19};

    for i = 1:m
      if disp, sp(m,1,i), else clf, end
      set(gca, 'NextPlot', 'add');
      
      plot_int(th, mu_sh(i,:), sd_sh(i,:), 'r', ind{i});
      plot_int(th, mu_lm(i,:), sd_lm(i,:), 'b');
      plot_int(th, mu_kf(i,:), sd_kf(i,:), 'k');
      %plot([0 90], [2 30], 'k--', 'LineWidth', 2);
      post(disp);
      if ~disp, prnt([fn '_' int2str(i)]); end
    end
  end
end

function post(disp)
  set(gca, 'XLim', [-1 90.5], 'XTick', 0:15:90)
  if ~disp, set(gca, 'FontSize', 50, 'FontName','Times'); end
  set(gca, 'YLim', [0 20], 'YTick', 0:5:30, 'YGrid', 'on');
  if ~disp, xlabel('crossing angle (ground truth)'); end
  if ~disp, ylabel('error in reconstructed angle'); end
end


function [mu sd] = stats(e)
  mu = cellfun(@(x) mean(x(isfinite(x))), e) * 180/pi;
  sd = cellfun(@(x)  std(x(isfinite(x))), e) * 180/pi;
end
