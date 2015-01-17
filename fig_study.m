function fig_study

  disp = true;

  clf
  prnt = @(fn) print('-dpng', '-r100', ['figs/miccai_study/' fn]);

  fn = 'study_stats_yi';
  [r03 r24 r28] = loadsome(fn, 'r03', 'r24', 'r28');
  R = [r03 r24 r28];
  fprintf('r03  nc %2d  sz %2d\n', size(r03.nc.mu1,3), size(r03.sz.mu1,3));
  fprintf('r24  nc %2d  sz %2d\n', size(r24.nc.mu1,3), size(r24.sz.mu1,3));
  fprintf('r28  nc %2d  sz %2d\n', size(r28.nc.mu1,3), size(r28.sz.mu1,3));

  m = size(r03.sig1,2);
  
  m_label = {'FA'       'fa2'      'trace'      'norm'       'RD'};
  m_lim   = {[0 .25 .5] [0 .25 .5] [0 3 6]/1000  0:.001:.004  [0 .5 1]};

  for i = 1:m
    for j = 1:3
      if disp, sp(m,3,3*(i-1)+j), else clf, end
      plot_his(R(j), i, m_label{i}, m_lim{i}, disp);
      if ~disp, prnt([fn '_' int2str(j) '_' m_label{i}]); end
    end
  end
end


function plot_his(R, i, label, lim, disp)
  set(gca, 'NextPlot', 'add');
  sig_max = lim(end)/5 * 1.3;
  
  plot(100*[-1 1], sig_max([1 1]), ...
       iff(disp, 'y--', 'k--'), ...
       'LineWidth', 3);

  plot_her(R.bins, sq(R.nc.mu1(i,:,:)), sq(R.sz.mu1(i,:,:)), 'b');
  s = R.sig1(:,i);
  ind = isfinite(s) & s <= .05;
  plot_p(R.bins(ind), s(ind), sig_max, 'b');

  plot_her(R.bins, sq(R.nc.mu2(i,:,:)), sq(R.sz.mu2(i,:,:)), 'r');
  s = R.sig2(:,i);
  ind = isfinite(s) & s <= .05;
  plot_p(R.bins(ind), s(ind), sig_max, 'r');
  
  fig_study_post(disp, label, lim);
end
function plot_her(bins, nc, sz, color)
  nc = mean_nan(nc);
  sz = mean_nan(sz);
  plot(bins,nc,color, bins,sz,[color '-.'], 'LineWidth', 4);
end
function plot_p(x, sig, sig_max, c)
  n = numel(x);
  if n == 0, return; end

  sig = sig * sig_max / 0.05;
  foo = cell(1,3*n);
  for i = 1:n
    foo{3*(i-1)+1} = x(i)*[1 1];
    foo{3*(i-1)+2} = [0 sig(i)];
    foo{3*(i-1)+3} = c;
  end
  foo{end+1} = 'LineWidth';
  foo{end+1} = 3;
  plot(foo{:});
  plot(x, sig, [c '.'], 'MarkerSize', 40);
end


function fig_study_post(disp, yy, lim)
  set(gca, 'XLim', 50*[-1 1], 'XTick', [])
  if ~disp, set(gca, 'FontSize', 32); end
  
  lims = {};
  for l = lim
    lims{end+1} = num2str(l);
  end

  set(gca, 'YLim', lim([1 end]), 'YTick', lim, 'YGrid', 'off', ...
           'YTickLabel', str2mat(lims{:}));

%   if ~disp, xlabel('arc length'); end
  if ~disp, ylabel(yy); end
  box off
end
