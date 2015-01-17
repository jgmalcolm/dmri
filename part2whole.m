function f_ = part2whole(f)
  assert(is_even(numel(f)));
  f_ = cell(1, numel(f)/2);

  for i = 1:numel(f_)
    f1 = f{2*(i-1)+1}(:,end:-1:1);
    f2 = f{2*(i-1)+2};
    % trim center point
    if ~isempty(f1)       f1 = f1(:,1:end-1);
    elseif ~isempty(f2)   f2 = f2(:,2:end); end
    % slap together
    f_{i} = [f1 f2];
  end
  
end
