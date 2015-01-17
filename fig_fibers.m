th = 30:15:90;

load matlab_X_b3000
load matlab_X_b3000_kf
load matlab_X_b3000_sh8_006

xx = [34 12; 34 11; 35 12; 35 11]';


clf
for i = 1:5
  sp(1,5,i)
  show_glyphs(signal2ga(tract(i).S), fibers_kf{i});
  axis on; set(gca, 'XTick', [], 'YTick', [], 'YLim', [15 55]);
  xlabel(th(i), 'FontSize', 18)
end
%print('-dpng', '-r200', 'figs/fibers_b3000');
