function batch_sh
  tic
  % params
  sh.L = 8;  sh.lambda = .006;  % Maxime
  %sh.L = 4;  sh.lambda = .004;  % Schultz
  
  sh.w_min = .5;

  % pre-generate permutations
  sh.max = 10;
  for i = 3:sh.max
    p = perms(1:i);
    pp{i} = unique(p(:,1:2), 'rows');
  end

  for b = 1000
    fn = sprintf('matlab_2cross_w_b%d', b);
    [tract u] = loadsome([fn '_SH'], 'tract', 'u');

    [f_sh S_sh F_sh] = deal(cell(size(tract)));
    for i = 1:numel(tract)
      T = tract(i);
      fprintf('SH: b=%d  th %2d  sigma %.1f  w %.1f  ', b, T.th, T.sigma, T.w);
      [f S F] = fiber_2sh(T.S, T.is_cross, u, T.th, sh, pp);
      f_sh{i} = f; S_sh{i} = S; F_sh{i} = F;
      fprintf('\n');
    end
    
    sh2x([fn '_2T_SH'],  @sh2T,  f_sh, F_sh, S_sh, sh);
  end
  toc
end


function sh2x(fn, fun, f_sh, F_sh, S_sh, sh)
  fn
  f_sh = map(fun, f_sh);
  save(fn, 'f_sh', 'S_sh', 'F_sh', 'sh');
end

function X = sh2W(X)
  X = X{1}; n = size(X,2);
  K = ones(1,n);
  X = {[X([1:2 3:5],:); K; X([6:8],:); K]};
end
function X = sh2T(X)
  X = X{1}; n = size(X,2);
  L = [1200 100]' * ones(1,n);
  X = {[X([1:2 3:5],:); L; X([6:8],:); L]};
end
function X = sh3T(X)
  X = X{1}; n = size(X,2);
  L = [1200 100]' * ones(1,n);
  X = {[X([1:2 3:5],:); L; X(6:8,:); L; X(9:11,:); L]};
end
function X = sh2TW(X)
  X = X{1}; n = size(X,2);
  LW = [1200 100 .5]' * ones(1,n);
  X = {[X([1:2 3:5],:); LW; X([6:8],:); LW]};
end
function X = sh3TW(X)
  X = X{1}; n = size(X,2);
  LW = [1200 100 .5]' * ones(1,n);
  X = {[X([1:2 3:5],:); LW; X(6:8,:); LW; X(9:11,:); LW]};
end
function X = shH(X)
  X = X{1}; n = size(X,2);
  wk = [1 .2]' * ones(1,n);
  X = {[X([1:2 3:5],:); wk; X([6:8],:); wk]};
end
