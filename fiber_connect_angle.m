function F2 = fiber_connect_angle(f1, f1_, f2, th)
  F2 = cell(1, numel(f2));

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
      
      % skip if angle too big
      [m1 l1 m2 l2] = state2tensor(f_end(4:13));
      if m1' * m2 < th
        continue
      end
        

      % where do I belong?
      ind = find(f_end(1) == f_start(1,:) & ...
                 f_end(2) == f_start(2,:) & ...
                 f_end(3) == f_start(3,:));
      
      F2{ii-1} = [f_start(:,1:ind-1) f_end];
    end
  end
  F2 = empty(F2);
end
