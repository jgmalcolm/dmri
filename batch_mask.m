function [D patients is_included] = batch_mask
  paths;

  patients = read_group('mask');
  %patients(1:find(patients == 1067)) = []; % skip some
  n = numel(patients);
  
  D = cell(n,2);
  for i = 1:n
    p = patients(i);
    D{i,1} = p;
    D{i,2} = grab_tensors(p);
  end
  is_included = cellfun(@isnumeric, {D{:,2}});
  
  % save
  fn = '/home/malcolm/src/lmi/patients_mask';
  fprintf('saving %d patients...\n', nnz(is_included));
  save(fn, 'D', 'patients', 'is_included');
end

function D = grab_tensors(id)
  
  % load patient
  fn = sprintf('/tmp/mask/%05d.raw', id);
  D = nhdr2mat(fn, 'single', [7 144 144 85]);
  
  D = reshape(D, 7, []);
  D = D(2:end, D(1,:,:,:) ~= 0);

  % estimate tensors
  fprintf('%05d: found %d tensors...\n', id, size(D,2));
end

