function fig_weight_post(disp)
  set(gca, 'XLim', [14 90.5], 'XTick', 15:15:90)
  if ~disp, set(gca, 'FontSize', 25); end
  set(gca, 'YLim', [.3 .9], 'YTick', .3:.1:.9, 'YGrid', 'on');
  if ~disp, xlabel('crossing angle (ground truth)'); end
  if ~disp, ylabel('estimated weight'); end
end
