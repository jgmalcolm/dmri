disp = false;

load matlab_2cross_w_b1000_zoom
load matlab_2cross_w_b1000_zoom_2TW

fn = 'figs/tw_HBM/zoom_2TW_b1000';
prnt = @(fn) print('-dpng', '-r200', fn);

% grab spatial positions
xx = f_kf{1}(1:2,:);
f_kf_ = filter_crossing(f_kf, T.is_cross);
xx_ = f_kf_{1}(1:2,:);

clf
if disp; colormap jet; sp(1,2,1); else colormap(gray); end
imagesc(signal2ga(T.S)); axis image off;
set(gca, 'XLim', [0 20]+.5, 'YLim', [10 60]+.5);
hold on;
plot(xx(2,:), xx(1,:), 'r', 'LineWidth', 1.5);
plot([9 11 11 9 9]+.5, [38 38 32 32 38], 'b', 'LineWidth', 3);
hold off;

if ~disp, set(gca, 'Position', [0 0 1 1]); prnt([fn '_fiber']); end

h_sep = 1.5;
fx = 10;

if disp; sp(1,2,2); else; clf; colormap jet; end;
hold on;
plot(xx(2,:),         xx(1,:), 'r', 'LineWidth', 1.5);
plot(xx(2,:) + h_sep, xx(1,:), 'r', 'LineWidth', 1.5);
axis ij equal
set(gca, 'XLim', [9 11+h_sep]+.5, 'YLim', [31.5 37.5]);

for i = 1:size(F_kf,2)
  x = [xx_(:,i); 0];
  if x(1) < 32 || x(1) > 37, continue, end
  % SH
  f = F_sh(:,i);  m = M_sh(:,:,i);
  f = minmax(f) / 2.2;
  odf_axes(f, u, m, x, 'k');
  % UKF
  f = F_kf(:,i);  m = M_kf(:,:,i);
  odf_axes(f*24, u, m, x + [0 h_sep 0]', 'k');
end


set(gca, 'XTick', [10.5 12], ...
         'XTickLabel', str2mat('SH', 'filtered'), ...
         'YTick', [], ...
         'FontSize', 18);


if ~disp
  set(gca, 'Position', [0 .07 1 .95]);
  prnt([fn '_zoom']);
end
