function batch_patients
  paths
  
  fid = fopen('patients.txt', 'r');
  id = fscanf(fid, '%d', inf)';
  fclose(fid);
  
  lbl = {1003 2003 1024 2024 1028 2028};

  i = 1;
  for id = id
    fprintf('case%05d\n', id);
    [S m u b wm gm] = load_patient(id);
    
%     for j = 1:numel(lbl)
%       [xx yy zz] = ind2sub(size(gm), find(gm == lbl{j}));
%       X{i}{j} = [xx yy zz];
%     end

%     n03(i) = nnz(gm==1003|gm==2003);
%     n24(i) = nnz(gm==1024|gm==2024);
%     n28(i) = nnz(gm==1028|gm==2028);
    
%     fprintf('case%05d  %4d   %4d   %4d  %4d\n', ...
%             id, n03(i), n24(i), n28(i), nnz(m));
    
    i = i + 1;
  end

%   xx = 1:numel(n03);
%   plot(xx,n03,'r', xx,n24,'b', xx,n28,'k');
end
