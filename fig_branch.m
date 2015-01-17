colormap gray
load matlab_branch_block_b1000
load matlab_branch_b1000_tensor_kf

clf
for i = 1:3
  sp(1,3,i);
  th = tract(i).angle;
  imagesc(signal2ga(tract(i).S)); axis image
  hold on;
  show_fibers(pri{i}, 'r');
  show_fibers(sec{i}, 'b');
  hold off; box off;
  set(gca, 'XLim', [2 18], 'XTick', [], 'YTick', [], 'YLim', [1 30]);
  xlabel(th, 'FontSize', 18)
  %print('-dpng', sprintf('figs/branching_b3000_%d', th));
end
print('-dpng', '-r100', 'figs/branching_b1000');



load matlab_branch_block_b3000
load matlab_branch_b3000_tensor_kf

for i = 1:3
  sp(1,3,i);
  th = tract(i).angle;
  imagesc(signal2ga(tract(i).S)); axis image
  hold on;
  show_fibers(pri{i}, 'r');
  show_fibers(sec{i}, 'b');
  hold off; box off;
  set(gca, 'XLim', [2 18], 'XTick', [], 'YTick', [], 'YLim', [1 30]);
  xlabel(th, 'FontSize', 18)
  %print('-dpng', sprintf('figs/branching_b3000_%d', th));
end
print('-dpng', '-r100', 'figs/branching_b3000');
