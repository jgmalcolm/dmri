function fig_angle_post(disp)
  set(gca, 'XLim', [14 90.5], 'XTick', 15:15:90)
  if ~disp, set(gca, 'FontSize', 25); end
  set(gca, 'YLim', [0 20], 'YTick', 0:5:20, 'YGrid', 'on');
  if ~disp, xlabel('crossing angle (ground truth)'); end
  if ~disp, ylabel('error in reconstructed angle'); end
end
