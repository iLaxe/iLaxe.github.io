function Grid = defaultGrid(varargin)
%DEFAULTGRID Default computational grid.
%
% Lx, Ly, and Lz are full computational lengths. The underlying k-space code
% uses x in [-Lx/2, Lx/2], y in [-Ly/2, Ly/2], and z in [0, Lz].

ip = inputParser;
ip.addParameter('Lx', 0.32);
ip.addParameter('Ly', 0.32);
ip.addParameter('Lz', 24);
ip.addParameter('dxUltra', 0.0025);
ip.addParameter('dyUltra', 0.0025);
ip.addParameter('dxAudio', 0.01);
ip.addParameter('dyAudio', 0.01);
ip.addParameter('dz', 0.005);
ip.parse(varargin{:});
opt = ip.Results;

Grid.xmax = opt.Lx;
Grid.ymax = opt.Ly;
Grid.zmax = opt.Lz;
Grid.deltax_max = opt.dxUltra;
Grid.deltay_max = opt.dyUltra;
Grid.deltax = opt.dxUltra;
Grid.deltay = opt.dyUltra;
Grid.deltax_audio = opt.dxAudio;
Grid.deltay_audio = opt.dyAudio;
Grid.deltaz = opt.dz;
end
