function [F2 I2] = fiber_connect(f1, f1_, f2)
  F2 = cell(1, numel(f2));
  I2 = zeros(1,numel(f2), 'uint16');

  nn = cellfun(@(f) size(f,2), f1_);
  ii = 1;
  for i = 1:numel(nn)
    f_start = f1{i};
    for j = 1:nn(i)
      f_end = f2{ii};
      ii = ii + 1;
      if isempty(f_end)
        continue
      end

      % where do I belong?
      ind = find(f_end(1) == f_start(1,:) & ...
                 f_end(2) == f_start(2,:) & ...
                 f_end(3) == f_start(3,:));
      
      I2(ii-1) = i;
      F2{ii-1} = [f_start(:,1:ind-1) f_end];
    end
  end
end
