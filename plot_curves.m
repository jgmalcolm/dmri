function plot_curves
  origin = [72 72 42.5];
%   clf;
  [F nc sz] = batch_curves(03, origin);
%   sp(3,2,1);
  sp(3,2,5);
  plot(nc.bins,nc.mu_1,'b',nc.bins,nc.mu_2,'r', ...
       sz.bins,sz.mu_1,'b:',sz.bins,sz.mu_2,'r:')
  legend('1T NC', '2T NC', '1T SZ', '2T SZ')
  set(gca, 'XTick', [], 'YLim', [0 .5], 'XLim', 50*[-1 1]);
  title('03')
  box off
  drawnow

  [F nc sz] = batch_curves(24, origin);
%   sp(3,2,2);
  sp(3,2,6);
  plot(nc.bins,nc.mu_1,'b',nc.bins,nc.mu_2,'r', ...
       sz.bins,sz.mu_1,'b:',sz.bins,sz.mu_2,'r:')
  legend('1T NC', '2T NC', '1T SZ', '2T SZ')
  set(gca, 'XTick', [], 'YLim', [0 .5], 'XLim', 50*[-1 1]);
  title('24');
  box off
  drawnow
  
  return
  [F nc sz] = batch_curves(28, origin);
  sp(3,1,3);
  plot(sz.bins,sz.mu_1,'b:',sz.bins,sz.mu_2,'r:')
  legend('1T SZ', '2T SZ')
  set(gca, 'XTick', [], 'YLim', [0 .5], 'XLim', 50*[-1 1]);
  title('24');
  box off
end
