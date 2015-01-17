function fig_compensate

%   gcf_ = get(gcf, {'PaperSize' 'PaperPosition'});
%   set(gcf, 'PaperSize',  [4 6], 'PaperPosition', [0 0 4 6])

  disp = false;
  
  fn = sprintf('matlab_2cross_w_b1000');
  [tt u b] = loadsome(fn, 'tract', 'u', 'b');
  ff = loadsome([fn '_2T_KF'], 'ff');
  M = tt(1).is_cross;
  tt = tt(:,end,1);
  ff = map(@(f,m) filter_crossing(f,M), ff(:,end,1));
  ff = map(@(f) reorient([f{:}]), ff);
  
  fn = sprintf('figs/tensor_2t/compensate_b%d', b);
  prnt = @(fn) print('-dpng', '-r200', fn);
  
  % grab ROI ODFs
  [F M] = map(@(f) odfs(f, u, b), ff);
  
  h_sep = 2;
  v_sep = 2;

  %%-- display fiber with ROI
  clf, hold on, colormap jet
  ii = 21;  % ii=4
  for i = 1:3
    x = ff{i}([6 7 11 12],ii)
    f = F{i}(:,ii);  m = M{i}(:,:,ii);
    f = minmax(f) / 1.3;
    odf_axes(f, u, m, [0; i*h_sep; 0]);

    m = [-1 0 0; 0 1 0]';
    f1 = tensor_odf([-1 0 0 1200 100], u, b);
    f2 = tensor_odf([ 0 1 0 1200 100], u, b);
    f = tt(i).w*f1 + (1-tt(i).w)*f2;
    f = minmax(f) / 1.3;
    odf_axes(f, u, m, [v_sep; i*h_sep; 0]);
  end
  axis image

  set(gca, 'XTick', [2 4 6], ...
           'XTickLabel', str2mat('50-50', '60-40', '70-30'), ...
           'YTick', [0 2], ...
           'YTickLabel', str2mat('est', 'true'), ...
           'FontSize', 18);
  
  if ~disp
    set(gca, 'Position', [.1 0 .9 1]);
    prnt(fn);
  end
end


function X = reorient(X)
  is_flip = X(3,:) > X(8,:);
  a = X(3:7,is_flip);
  b = X(8:12,is_flip);
  X(3:12,is_flip) = [b;a];
end


function [F M] = odfs(X, u, b)
  X = X(3:end,:);
  for i = 1:size(X,2)
    [m1 l1 m2 l2] = state2tensor(X(:,i));
    F1 = tensor_odf([m1; l1], u, b);
    F2 = tensor_odf([m2; l2], u, b);
    F(:,i) = F1 + F2;
    M(:,:,i) = [m1 m2];
  end
end
