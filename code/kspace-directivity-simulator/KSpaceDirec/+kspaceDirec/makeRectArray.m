function Array = makeRectArray(width, height, velocity, varargin)
%MAKERECTARRAY Create a continuous rectangular aperture source.

ip = inputParser;
ip.addParameter('x', 0);
ip.addParameter('y', 0);
ip.parse(varargin{:});
opt = ip.Results;

Array = kspaceDirec.local_base_array(opt.x(:), opt.y(:), velocity);
Array.src = 'rec';
Array.ax = width / 2;
Array.ay = height / 2;
end
