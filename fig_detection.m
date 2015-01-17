function fig_detection
  th = 15:5:90;
  %W  = .5:.1:.8;
  %W = [.33 .50 .60];
  W = .33;
  m = numel(W);

  disp = true;

  prnt = @(fn) print('-dpng', '-r100', fn);

  for b = [1000]
    fn = sprintf('matlab_3cross_w_b%d_3TW_e', b);
    [e_kf e_sh] = loadsome(fn, 'e_kf', 'e_sh');
    
    e_kf = map(@(e) e(1,:), e_kf);
    e_sh = map(@(e) e(1,:), e_sh);

    % detection rates
    r_kf = cellfun(@(e) 1-nnz(isinf(e))/numel(e), e_kf);
    r_sh = cellfun(@(e) 1-nnz(isinf(e))/numel(e), e_sh);
    
    fn = sprintf('figs/tw_HBM/detection_3TW_b%d', b);

    clf
    
    i = 1;
    for ww = W
      if disp, sp(m,2,2*(i-1)+1), else clf, end
      
      plot(th, r_sh(i,:,1), 'r', th, r_kf(i,:,1), 'k', 'LineWidth', 4);
      fig_detection_post(disp)
      if ~disp, prnt([fn '_clean_' int2str(i)]); end
      i = i + 1;
    end % w
    
    i = 1;
    for ww = W
      if disp, sp(m,2,2*i), else clf, end

      plot(th, r_sh(i,:,2), 'r', th, r_kf(i,:,2), 'k', 'LineWidth', 4);
      fig_detection_post(disp)
      if ~disp, prnt([fn '_dirty_' int2str(i)]); end
      i = i + 1;
    end % w
  end
end

function fig_detection_post(disp)
  set(gca, 'XLim', [14 90.5], 'XTick', 15:15:90)
  if ~disp, set(gca, 'FontSize', 25); end
  set(gca, 'YLim', [0 1.01], ...
           'YTick', [0 .5 1], ...
           'YTickLabel', str2mat('0.0', '0.5', '1.0'), ...
           'YGrid', 'on');
  if ~disp, xlabel('crossing angle (ground truth)'); end
  if ~disp, ylabel('detection rate'); end
  box off
end
