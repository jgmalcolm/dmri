colormap jet
th = [40 50 60];

load matlab_cross_block_b3000
load matlab_branch_b3000_tensor_compare

xx = [14 12; 14 11; 15 12; 15 11]';


v_sep = 160;
h_sep = 0;

clf;
for i = 1:3
  f_kf = fibers_kf{i};
  f_sh = fibers_sh{i};
  f_sh_odf = fibers_sh_F{i};
  for j = 1:4
    x = xx(:,j);
    
    % prepare Watson ODF
    X = find_state(x, f_kf);
    m_kf = X([3:5; 8:10]');
    F_kf = tensor_odf(X(3:7), u, b) + tensor_odf(X(8:12), u, b);
    F_kf = 1.3*minmax(F_kf);
    
    % prepare fODF
    [X F_sh] = find_state(x, f_sh, f_sh_odf);
    m_sh = X([3:5; 8:10]');
    F_sh = minmax(F_sh);
    
    x = [60 40 0]'.*[x;0] + 150*(i-1)*[0 1 0]';
    
    odf(20*F_sh, u, fcs, x-[v_sep h_sep 0]'); odf_axes(25*m_sh, x-[v_sep h_sep 0]');
    odf(20*F_kf, u, fcs, x); odf_axes(25*m_kf, x);
  end
end

axis image ij;
set(gca, 'XTick', [460 610 760], ...
         'XTickLabel', int2str([40 50 60]'), ...
         'YTick', [710 870], ...
         'YTickLabel', str2mat('  fODF', 'filtered'), ...
         'FontSize', 18);

% indicate errors
hold on;
xx = [440 680; 480 680];
plot(xx(:,1),xx(:,2),'ro','LineWidth',2,'MarkerSize',56);

print('-dpng', '-r200', 'figs/fibers_b3000_zoom');
