function fig_angle
  th = 15:5:90;
  sh_ind = {9:16  7:16}; % 2T
  kf_ind = { 1:16  1:16}; % 2T
%   sh_ind = {11:16  9:16}; % 3T
%   kf_ind = { 6:16  6:16}; % 3T

  disp = false;
  
  gr = .7*[1 1 1];

  clf

  i = 1;
  for b = [1000 3000]
    fn = sprintf('matlab_2cross_b%d_2T_e', b);
    [e_kf e_pp e_sh] = loadsome(fn, 'e_kf', 'e_pp', 'e_sh');
    fn = sprintf('figs/tensor_NI/bw/angle_2T_b%d', b);
%     fn = sprintf('matlab_3cross_b%d_3T_e', b);
%     [e_kf e_sh] = loadsome(fn, 'e_kf', 'e_sh');
%     fn = sprintf('figs/tensor_NI/angle_3T_b%d', b);
    % angles
    [mu_kf sd_kf] = stats(e_kf);
    [mu_pp sd_pp] = stats(e_pp);
    [mu_sh sd_sh] = stats(e_sh);

    
    if disp, sp(2,4,i), i = i + 1; else clf, end
    set(gca, 'NextPlot', 'add');
    plot_int(th, mu_pp(1,:), sd_pp(1,:), gr);
    plot_int(th, mu_kf(1,:), sd_kf(1,:), 'k');
    fig_angle_post(disp);
    if ~disp, print('-dpng', '-r100', [fn '_PP_clean']); end

    if disp, sp(2,4,i), i = i + 1; else clf, end
    set(gca, 'NextPlot', 'add');
    plot_int(th, mu_pp(2,:), sd_pp(2,:), gr);
    plot_int(th, mu_kf(2,:), sd_kf(2,:), 'k');
    fig_angle_post(disp);
    if ~disp, print('-dpng', '-r100', [fn '_PP_dirty']); end
    
    if disp, sp(2,4,i), i = i + 1; else clf, end
    set(gca, 'NextPlot', 'add');
    plot_int(th(:), mu_sh(1,:), sd_sh(1,:), gr, sh_ind{1});
    plot_int(th(:), mu_kf(1,:), sd_kf(1,:), 'k', kf_ind{1});
    fig_angle_post(disp);
    if ~disp, print('-dpng', '-r100', [fn '_SH_clean']); end
    
    if disp, sp(2,4,i), i = i + 1; else clf, end
    set(gca, 'NextPlot', 'add');
    plot_int(th(:), mu_sh(2,:), sd_sh(2,:), gr, sh_ind{1});
    plot_int(th(:), mu_kf(2,:), sd_kf(2,:), 'k', kf_ind{1});
    fig_angle_post(disp);
    if ~disp, print('-dpng', '-r100', [fn '_SH_dirty']); end
    sh_ind = {sh_ind{2:end}};
    kf_ind = {kf_ind{2:end}};
  end
end




function [mu sd] = stats(e)
  mu = cellfun(@(e) mean(e(~isinf(e))), e) * 180/pi;
  sd = cellfun(@(e)  std(e(~isinf(e))), e) * 180/pi;
end
function fig_angle_post(disp)
  set(gca, 'XLim', [14 90.5], 'XTick', 15:15:90)
  set(gca, 'YLim', [0 25], 'YTick', 0:5:25, 'YGrid', 'on');
  if disp, return, end
  set(gca, 'FontSize', 25);
  xlabel('crossing angle (ground truth)');
  ylabel('error in reconstructed angle');
end
