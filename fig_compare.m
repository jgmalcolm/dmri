load matlab_branch_block_b3000
load matlab_2cross_X_b3000_2W

clf
for i = 1:3
  sp(1,3,i);
  th = tract(i).angle;
  hold on;
  show_glyphs(signal2ga(tract(i).S), fibers_kf{i}, param);
  axis image ij; box off;
  set(gca, 'XLim', [2 18], 'YLim', [1 30]);
  set(gca, 'XTick', [], 'YTick', []);
  xlabel(th, 'FontSize', 18)
  hold off;
end
print('-dpng', '-r100', 'figs/compare_b3000_2W');
