function fig_cross
  disp = false;

  for b = [1000 3000]
    fn = sprintf('matlab_2X_b%d', b);
    tract = loadsome(fn, 'tract');
    [fibers_kf param] = loadsome([fn '_2T_KF'], 'fibers_kf', 'param');

    clf
    n = numel(tract);
    for i = 1:n
      sp(1,n,i);
      th = tract(i).th;
      show_glyphs(signal2ga(tract(i).S), fibers_kf{i}, param);
      axis image; box off;
      set(gca, 'XLim', [2 18], 'XTick', [], 'YTick', [], 'YLim', [20 50]);
      xlabel(th, 'FontSize', 18)
      % plot([4 17 17 4 4], [9 9 62 62 9], 'w', 'LineWidth', 1.5);
    end
    if ~disp
      print('-dpng', '-r100', sprintf('figs/tensor_NI/cross_b%d_2T', b));
    end
  end
end
