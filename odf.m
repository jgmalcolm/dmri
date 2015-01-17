function odf(F, u, fcs, origin)
% Visualize spherical functions
%
% ODF(F,u,fcs) visualizes the samples P of a function defined at N points u of
% the unit sphere, where u is an N-by-3 sampling matrix.
%
% ODF(F,u,fcs,origin) centers the function at specified origin.
%
% Input:
%               F - values of the function to be visualized
%               u - samples of the unit sphere
%             fcs - "vertices-to-face" correspondence matrix      
%          origin - center point (default: [0 0 0])
%
% written by Oleg Michailovich, September 2007

  [th phi] = cart2sph(u(:,1), u(:,2), u(:,3));
  [x y z] = sph2cart(th, phi, F);

  if nargin == 2
    fcs = convhulln(u);
  end

  % shift
  if nargin == 4
    x = x + origin(1);
    y = y + origin(2);
    z = z + origin(3);
  end

  patch('Vertices', [y x z], 'Faces', fcs, ...
        'FaceVertexCData', F, 'FaceColor', 'interp', ...
        'EdgeColor', 'none');
end
