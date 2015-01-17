function F = connect_full(f1, f1_, f2)
  F2 = cell(1, numel(f2));
  I2 = zeros(1,numel(f2), 'uint16');
  
  % prepend secondaries with their primary
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
  
  % prepend everything with its other half
  F1 = connect(f1); % odds same, evens reversed/prepended
  f1_rev  = rev(f1);
  % connect up primaries
  F2_= arrayfun(@(i,x) [f1_rev{other(i)} x{1}], I2, F2, 'Un',0);
  F = {F1{:} F2_{:}};
  F = empty(F);
end

function b = other(a)
  b = iff(even(a), a - 1, a + 1);
end


% reverse along columns
function xx = rev(xx)
  xx = map(@(x) x(:,end:-1:1), xx);
end
