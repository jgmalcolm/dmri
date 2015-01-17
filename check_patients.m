function check_patients
  
  for p = read_group('1T')
    check(p);
  end

end

function check(id)

  base = sprintf('/projects/schiz/3Tdata/case%05d', id);
  
  S = sprintf('%s/diff/%05d-dwi-filt-Ed.nhdr', base, id);
  m = sprintf('%s/diff/Tensor_mask-%05d-dwi-filt-Ed_AvGradient-edited.raw.gz', base, id);
  wm = sprintf(['%s/projects/20071213-usman-coreg/1_transform_tst/' ...
                'xformed_case%05d_ICBM_WMPM.raw.gz'], base, id);
  gm = sprintf(['%s/projects/20080611-dougm-deformation/' ...
                '%05d-freesurferseg-def.nrrd'], base, id);
  
  if ~exist(S),  fprintf('%05d missing signal\n', id); end
  %if ~exist(m),  fprintf('%05d missing mask\n', id); end
  if ~exist(wm), fprintf('%05d missing usman-coreg\n', id); end
  %if ~exist(gm), fprintf('%05d missing dougm-deformation\n', id); end
end
