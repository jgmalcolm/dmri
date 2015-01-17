function resume_patient(id, label, i0)
  paths;
  [S mask u b wm gm] = load_patient(id);
  
  % prepare seeds
  isL = gm==(1000+label);   isR = gm==(2000+label);
  
  % prepare output directories
  assert(exist(sprintf('%s/%05d', tempdir, id), 'dir') ~= 0);
  base = '/projects/schiz/pi/malcolm';
  fn_tmp = sprintf('%s/%05d/%05d_%02d_', tempdir, id, id, label);
  fn_fa  = sprintf(  '%s/fa/%05d_%02d_', base,        id, label);
  fn_fa_ = sprintf( '%s/fa_/%05d_%02d_', base,        id, label);

  [f0 param] = loadsome([fn_tmp int2str(i0)], 'f_', 'param');
  param.len_min = 0;

  for i = i0+1:3
    is_last = (i == 3);
    n = sum(cellfun(@(s) size(s,2), f0));
    [f f_] = deal(cell(1, n));
    j = 1;
    for X = f0
      for X = X{1}
        [f{j} f_{j}] = follow3d_2t(S, u, b, mask, X, is_last, param);
        fprintf('%05d %02d %d %2.0f%% (%d/%d)\n', ...
                id, label, i, 100*j/n, j, n);
        j = j + 1;
      end
    end
    % save intermediates in local /tmp and /projects/schiz/.../tmp
    i_ = int2str(i);
    save([fn_tmp i_], 'f', 'f_', 'param');
    save([fn_fa_ i_], 'f', 'f_', 'param');

    if i == 3
      % save finals in /projects/schiz...
      ff = fibers2cortical(fn_tmp, isL, isR, 3);
      fprintf('fiber count: %d\n', numel(ff));
      save([fn_fa i_], 'ff', 'param');
    end

    if isempty(f_), break, end
    f0 = f_;
    param.len_min = 0;
  end
end
