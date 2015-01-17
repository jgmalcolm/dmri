function fig_method(id,lbl)
  id = 1026;
  lbl = 03;
  fn = sprintf('/projects/schiz/pi/malcolm/fa/%05d_%02d_3', id, lbl);
  ff_2      = loadsome([fn      ], 'ff'      );
  [ff_1 mm] = loadsome([fn '_1t'], 'ff', 'mm');

  % trim and orient
  eig = 1; len = 95;
  T = [eye(3) [0 0 0]']; origin = [72 72 42.5];
  keep = cellfun(@(f) size(f,2) < len && size(f,2) > 25, ff_2);
  ff_2 = {ff_2{keep}}; ff_1 = {ff_1{keep}};
  [ff_1 ff_2] = cellfun(@orient, ff_1, ff_2, 'Un',0);
  vv_1 = cellfun(@f2v_1, ff_1, 'Un',0);
  
  % positive arc-length for display
  [xx ds     ] = fiber2arc(ff_2, mm, eig);
  ijk2tube(xx, sprintf('results/miccai_study/%05d_%02d_ds',id, lbl), ds);
  
  % binned FA for plotting
  [xx ss vv_2] = fiber2arc(ff_2, mm, eig, T, origin);
  [vv_1 bins] = ds2bin(ss, vv_1);
   vv_2       = ds2bin(ss, vv_2);
   
  vv_1 = cellfun(@(v) v(1,:), vv_1, 'Un',0);
  vv_2 = cellfun(@(v) v(1,:), vv_2, 'Un',0);

  mu_1 = mean(cat(3,vv_1{:}),3);
  mu_2 = mean(cat(3,vv_2{:}),3);
  
  clf;
  plot(bins,mu_1,'b',  bins,mu_2,'r', ...
       [-12 -12], [0 .5], 'w--', [12 12], [0 .5], 'w--', ...
       'LineWidth', 3);
  set(gca, 'XLim', 40*[-1 1], 'XTick', [], ...
           'YLim', [0 .5], 'YTick', 0:.1:.5, ...
           'FontSize', 23);
  ylabel('FA');
  box off
  legend('single tensor', 'two-tensor');
end

function [f g] = orient(f, g)
  if size(f,2) < 1, return, end
  if f(1,1) < f(1,end) % reversed?
    f = f(:,end:-1:1);
    g = g(:,end:-1:1);
  end
end


function fa = f2v_1(f)
  D  = f(4:9,:);

  D_ = D;
  tr = sum(D([1 4 6],:));
  D_([1 4 6],:) = D([1 4 6],:) - tr([1 1 1],:)/3;

  w = diag([1 2 2 1 2 1]);
  nrm = sqrt(sum(w*D.^2))+eps;
  fa = sqrt(3/2 * sum(w*D_.^2))./nrm;
end
