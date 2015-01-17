function [D patients is_included] = batch_wm_1T
%   D = grab_tensors(1021);
%   return
  
  paths;

  patients = read_group('1T');
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
  fn = '/home/malcolm/src/single';
  fprintf('saving %d patients...\n', nnz(is_included));
  save(fn, 'D', 'patients', 'is_included');
end

function D = grab_tensors(id)
  
  % load patient
  base = sprintf('/projects/schiz/3Tdata/case%05d', id);
  %S = sprintf('%s/diff/%05d-dwi-filt-Ed.nhdr', base, id);
  S = sprintf('/tmp/%05d.raw', id);
  wm = sprintf(['%s/projects/20080611-dougm-deformation/' ...
                '%05d-freesurferseg-def.nrrd'], base, id);
  if ~exist(S),  D = 'signal'; return; end
  if ~exist(wm), D = 'dougm';  return; end
  %[S u b] = nhdr_diff(S);
  D = nhdr2mat(S, 'single', [7 144 144 85]);
  D = shiftdim(D,1); D = D(:,:,:,2:end);
  wm = nrrdZipLoad(wm);
  wm = wm == 2 | wm == 41;
  
  is_256 = iff(size(wm,1) == 256, id, nan);

  % special cases
  switch id
   case 1063
    disp('flipping...');
    D = flipdim(D,3);
    wm = flipdim(wm,3);
   case is_256
    fprintf('cropping %05d...\n', id);
    a = (256 - 144)/2 + 1;
    b = a + 144 - 1;
    wm = wm(a:b,a:b,:);
  end
  assert(isequal(size(wm), size(D(:,:,:,1))));
  
  % grab white matter tensors
  D = reshape(D, [], 6);
  D = D(wm, :)';
  
  % estimate tensors
  fprintf('%05d: found %d tensors...\n', id, size(D,2));
end

