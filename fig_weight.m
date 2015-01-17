function fig_weight

  th = 15:5:90;
  W  = .5:.1:.8;
  %W = [.33 .50 .60];
  m = numel(W);

  disp = true;

  prnt = @(fn) print('-dpng', '-r100', fn);

  for b = [1000]
    fn = sprintf('matlab_2cross_w_b%d_2TW_e', b);
    [e_kf e_lm] = loadsome(fn, 'e_kf', 'e_lm');
    
    [mu_kf sd_kf] = stats(e_kf);
    [mu_lm sd_lm] = stats(e_lm);

    clf
    
    fn = sprintf('figs/tw_TMI/weight_2TW_b%d', b);
    
    ref_params = {'Color'  [0 .7 0] ...
                  'LineStyle'  '--' ...
                  'LineWidth' 4};

    for i = 1:m
      if disp, sp(m,1,i), else clf, end
      set(gca, 'NextPlot', 'add');
      plot(th([1 end]), W([1 1],i), ref_params{:});
      
      plot_int(th, mu_kf(i,:), sd_kf(i,:), 'k');
      plot_int(th, mu_lm(i,:), sd_lm(i,:), 'b');
      post(disp)
      if ~disp, prnt([fn '_' int2str(i)]); end
    end
  end

end


function post(disp)
  set(gca, 'XLim', [14 90.5], 'XTick', 15:15:90)
  if ~disp, set(gca, 'FontSize', 25); end
  set(gca, 'YLim', [.3 .9], 'YTick', .3:.1:.9, 'YGrid', 'on');
  if ~disp, xlabel('crossing angle (ground truth)'); end
  if ~disp, ylabel('estimated weight'); end
end




function [mu sd] = stats(e)
  e = map(@(e) e(2,:), e); % grab weights
  mu = cellfun(@(e) mean(e(~isinf(e))), e);
  sd = cellfun(@(e)  std(e(~isinf(e))), e);
end
