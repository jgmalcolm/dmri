function run_patient(id, lbl)
  paths;
  [S mask u b wm gm] = load_patient(id);
  if id == 1063
    disp('flipping...');
    S = flipdim(S,3);
    mask = flipdim(mask,3);
    wm = flipdim(wm,3);
    gm = flipdim(gm,3);
  elseif id == 1021
    disp('cropping...');
    a = (256 - 144)/2 + 1;
    b = a + 144 - 1;
    gm = gm(a:b,a:b,:);
  end
  assert(isequal(size(gm), size(S(:,:,:,1))));
  assert(isequal(size(wm), size(S(:,:,:,1))));
  assert(isequal(size(wm), size(gm)));
  
  for lbl = lbl
    run(id, lbl, S,mask,u,b,wm,gm);
  end
end



function run(id, label,   S,mask,u,b,wm,gm)
  param.velocity = 1;
  param.ode = odeset('MaxStep', param.velocity/10);
  param.GA_min = .1;
  param.len_min = 10;
  
  if label == 3, param.seeds = 20; param.close = 3;      % 3
  else           param.seeds = 7;  param.close = 0; end  % 24,28
  if label == 3
    switch id
     case 1034, param.seeds = 40
     case 1074, param.seeds = 30
    end
  end

  param.FA_min = .15;
  param.theta_min = cos( 5 * pi/180);
  param.theta_max = cos(40 * pi/180);

  param.Qm = .001;
  param.Ql = 10;
  param.Rs = .02;

  % prepare seeds
  isL = gm==(1000+label);   isR = gm==(2000+label);
  seeds = close_mask(isL|isR, param.close);
  if id == 1021
    f0 = init_fibers_2t(S, seeds, u, b, param);
  else
    f0 = init_fibers_2t_proj(S, seeds, u, b, param);
  end

  % prepare output directories
  err = mkdir(sprintf('%s/%05d', tempdir, id));
  base = '/home/malcolm/src/lmi/';
  fn_tmp = sprintf('%s/%05d/%05d_%02d_', tempdir, id, id, label);
  fn_fa  = sprintf( '%s/fa/%05d_%02d_',  base,    id, label);
  fn_fa_ = sprintf( '%s/fa_/%05d_%02d_', base,    id, label);

  for i = 1:3
    is_last = (i == 3);
    n = sum(cellfun(@(s) size(s,2), f0));
    [f f_] = deal(cell(1, n));
    j = 1;
    for X = f0
      for X = X{1}
        [f{j} f_{j}] = follow3d_2t(S, u, b, mask, X, is_last, param);
        fprintf('%05d %02d %d %2.0f%% (%6d/%6d)\n', ...
                id, label, i, 100*j/n, j, n);
        j = j + 1;
      end
    end
    % save intermediates in local /tmp and /net/lmi
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
