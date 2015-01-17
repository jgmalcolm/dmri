function fig_lambda_w
  set(0, 'DefaultAxesFontName', 'Helvetica', ...
         'DefaultTextFontName', 'Helvetica');

  th = [0 45 90];
  W  = [.5 .6 .7];
  l2  = 100:100:700;

  disp = true;

  prnt = @(fn) print('-dpng', '-r70', fn);

  n = numel(th);
  m = numel(W);

  for b = 1000
    fn = sprintf('matlab_2cross_lambda_b%d_2T_e', b);
    [e_kf e_1t e_lm] = loadsome(fn, 'e_kf', 'e_1t', 'e_lm');
    
    [mu_kf sd_kf] = stats(e_kf);
    [mu_1t sd_1t] = stats(e_1t);
    [mu_lm sd_lm] = stats(e_lm);

    fn = sprintf('figs/tensor_TMI/lambda_b%d', b);

    clf
    
    idx = 1;
    for i = 1:m
      for j = 1:n
        if disp, sp(m,n,idx), else clf, end
        set(gca, 'NextPlot', 'add');
        
%         plot(l2, flat(mu_1t(i,j,:)), 'LineWidth', 4, 'Color', [0 .7 0]);
%         plot(l2, flat(mu_lm(i,j,:)), 'LineWidth', 4, 'Color', 'b');
%         plot(l2, flat(mu_kf(i,j,:)), 'LineWidth', 4, 'Color', 'k');

        plot_int(l2, flat(mu_lm(i,j,:)), flat(sd_lm(i,j,:)), 'b');
        plot_int(l2, flat(mu_1t(i,j,:)), flat(sd_1t(i,j,:)), [0 .7 0]);
        plot_int(l2, flat(mu_kf(i,j,:)), flat(sd_kf(i,j,:)), 'k');
        post(disp);
        if ~disp, prnt(sprintf('%s_w%.0f_t%02d', fn, 100*W(i), th(j))), end
        idx = idx + 1;
      end
    end
  end
end

function post(disp)
  set(gca, 'XLim', [80 720], 'XTick', 100:200:700)
  if ~disp, set(gca, 'FontSize', 50, 'FontName','Times'); end
  set(gca, 'YLim', [0 .4], 'YTick', 0:.1:1, 'YGrid', 'on', ...
           'YTickLabel', str2mat('0', '0.1', '0.2','0.3', '0.4','0.6','0.8','1.0'));
  if ~disp, xlabel('minor eigenvalue'); end
  if ~disp, ylabel('error in estimated FA'); end
end


function [mu sd] = stats(e)
  mu = cellfun(@mean, e);
  sd = cellfun(@std,  e);
end
