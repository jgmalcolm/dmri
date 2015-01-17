function img = batch_color_cc(mask, xx, cc, k)
  n = numel(cc);
  img = zeros([85 144 n], 'uint32');
  
  for i = 1:n
    i
    m = compact(color_cc(mask, xx, cc{i}, k));
    img(:,:,i) = rot90(sq(m(73,:,:)),-1);
  end
end
