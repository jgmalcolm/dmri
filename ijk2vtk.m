function ijk2vtk(xx, name, varargin)
  paths;

  if isempty(xx), return, end
  
  p = myparams(varargin);

  try hdr = p.frame; catch hdr = @ReadNrrdHeader; end;
  
  if size(xx{1},1) > 3,  xx = map(@(x)x(1:3,:), xx); end

  if isfield(p, 'random_gray')
    p.scalars = random_gray(xx, p.random_gray);
  end

  M = hdr();
  R = M(1:3, 1:3);
  T = M(4,:);
  
  polyData(numel(xx)) = struct('x', []); % preallocate

  for i = 1:numel(xx)
    n = size(xx{i},2);
    t = R * xx{i};
    
    % create a polyData structure so that we can write it as a vtK File
    polyData(i).x = t(1,:) + T(1);
    polyData(i).y = t(2,:) + T(2);
    polyData(i).z = t(3,:) + T(3);
    
    if isfield(p, 'scalars')
      polyData(i).scalars = p.scalars{i};
    end
    
  end

  if isfield(p, 'tensors')
    polyData(1).tensors = p.tensors;
  end
       
  % save to VTK file
  savePoly(polyData, [name '.vtk']);
end



function savePoly(polyData, fName)
% save polyData to a vtkPolyData file with name fName
%
%   original: Marc Niethammer
%   scalars/tensors: Jimi Malcolm, Yogesh Rathi
%
% Input:
%   polyData: fiber array containing structs

  fid = fopen(fName, 'w');

  fprintf(fid, '# vtk DataFile Version 2.0\n');
  fprintf(fid, 'matlabPolyData\n');
  fprintf(fid, 'ASCII\n');
  fprintf(fid, 'DATASET POLYDATA\n');

  numberOfLines = length(polyData);
  % preallocate
  lengths = zeros(1, numberOfLines);
  indices(numberOfLines).ind = 0;

  offset = 0;
  indicesLength = 0;
  for fidx = 1:numberOfLines
    lengths(fidx) = length(polyData(fidx).x);
    indices(fidx).ind = offset + [1:lengths(fidx)] -1;
    offset = offset + lengths(fidx);
    indicesLength = indicesLength + length(indices(fidx).ind);
  end
  if numberOfLines > 0
    numberOfPoints = sum(lengths);
  else
    numberOfPoints = 0;
  end
  lengthOfCellData = indicesLength + numberOfLines;

  fprintf(fid, 'POINTS %d float\n', numberOfPoints);
  for fidx = 1:numberOfLines
    for pidx = 1:lengths(fidx)
      fprintf(fid, '%f %f %f\n', ...
              polyData(fidx).x(pidx), ...
              polyData(fidx).y(pidx), ...
              polyData(fidx).z(pidx));
    end
  end

  fprintf(fid, 'LINES %d %d\n', numberOfLines, lengthOfCellData);
  for fidx = 1: numberOfLines
    fprintf(fid, '%d ', [lengths(fidx) indices(fidx).ind ]);
    fprintf(fid, '\n');
  end

  % if there are scalar values
  if isfield(polyData, 'scalars')
    fprintf(fid, 'POINT_DATA %d \n', numberOfPoints);
    fprintf(fid, 'SCALARS scalar float 1\n');
    for fidx = 1:numberOfLines
      fprintf(fid, '%f ', polyData(fidx).scalars);
    end
  end
  
  % if there are tensor values
  if isfield(polyData, 'tensors')
    fprintf(fid, 'CELL_DATA %d \n', lengthOfCellData);
    fprintf(fid, 'POINT_DATA %d \n', numberOfPoints);
    fprintf(fid, 'TENSORS tensor float\n');
    fwrite(fid,polyData(1).tensors,'float');  %
  end

  fclose(fid);
end
