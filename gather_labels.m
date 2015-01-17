function gather_labels
  
  base = '/projects/schiz/pi/malcolm/fa';

  patients = read_group('all');
  labels = [03 24 28];



  label_sets = cell(1,numel(patients));
  for i = 1:numel(patients)
    id = patients(i);
    fprintf('case%05d...\n', id);
    gm = load_gm(id);
    for j = 1:numel(labels)
      lbl = labels(j);
      
      % left
      [xx yy zz] = ind2sub(size(gm), find(gm == 1000 + lbl));
      label_sets{i}{2*(j-1)+1} = [xx yy zz];
      
      % right
      [xx yy zz] = ind2sub(size(gm), find(gm == 2000 + lbl));
      label_sets{i}{2*(j-1)+2} = [xx yy zz];

    end
  end
  disp('saving...')
  save([base '/labels_03_24_28'], 'label_sets', 'patients', 'labels');
end


function gm = load_gm(id)
  paths
  base = sprintf('/projects/schiz/3Tdata/case%05d', id);
  gm = sprintf(['%s/projects/20080611-dougm-deformation/' ...
                '%05d-freesurferseg-def.nrrd'], base, id);
  gm = nrrdZipLoad(gm);
end
