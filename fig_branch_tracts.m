load matlab_branch_block_b1000
load matlab_branch_b1000_watson_kfsh

T = tract(2)
f_kf   = fibers_kf{2}{1};
f_kf_  = fibers_kf_{2}{1};
f_sh   = fibers_sh{2}{1};
f_sh_F = fibers_sh_F{2}{1};
x = xx{2};

if 0
clf; colormap gray;
imagesc(signal2ga(T.S)); axis image off;
show_fibers({f_kf}, 'r');
hold on;
plot([9.5 10.75 10.75 9.5 9.5], [13 13 17 17 13], 'b', 'LineWidth', 2);
hold off;
fn = 'figs/compare_tract.png';
print('-dpng', fn);
img = imread(fn);
imwrite(img(:,350:900,:), fn);

end

fx = 1.5;

clf; colormap jet
for i = 1:2
  %imagesc(signal2ga(T.S));
  f = f_kf;
  f(2,:) = f(2,:) + (i-1)*fx;
  show_fibers({f}, 'r');
  axis image ij; box on;
  set(gca, 'XLim', [9.5 10.75+fx], 'YLim', [13 17], ...
           'XTick', [10.2 11.6], 'XTickLabel', str2mat('fODF','UKF'), ...
           'YTick', [], 'FontSize', 20);
end

fcs = convhulln(u);

for i = 1:size(x,2)
  pos = [x(:,i);0];
  
  % SH8
  X = model_2watson_f(f_sh(3:10,i));
  m_sh = X([1:3; 5:7]') / 2.2;
  F_sh = f_sh_F(:,i);
  F_sh = 25*F_sh / sum(F_sh);
  odf(F_sh, u, fcs, pos); odf_axes(m_sh, pos);
  
  % UKF
  pos = pos + [0 fx 0]';
  X = model_2watson_f(f_kf_(3:10,i));
  m_kf = X([1:3; 5:7]') / 2.2;
  X([4 8]) = 4 * X([4 8]); % scale up K
  F_kf = watson_odf(u, X(1:4)) + watson_odf(u, X(5:8));
  F_kf = 17*F_kf / sum(F_kf);
  odf(F_kf, u, fcs, pos); odf_axes(m_kf, pos);

end
return
fn = 'figs/compare_tract_zoom.png';
print('-dpng', fn);
img = imread(fn);
imwrite(img(:,350:900,:), fn);
