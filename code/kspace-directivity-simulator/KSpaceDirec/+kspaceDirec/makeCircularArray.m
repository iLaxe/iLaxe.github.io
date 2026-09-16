function Array = makeCircularArray(radius, velocity, varargin)
%MAKECIRCULARARRAY Create one or more circular piston elements.

ip = inputParser;
ip.addParameter('x', 0);
ip.addParameter('y', 0);
ip.addParameter('velocity', velocity);
ip.parse(varargin{:});
opt = ip.Results;

x = opt.x(:);
y = opt.y(:);
if isscalar(y) && numel(x) > 1
    y = repmat(y, numel(x), 1);
end
if numel(x) ~= numel(y)
    error('x and y must have the same number of elements.');
end

v = opt.velocity;
if isscalar(v)
    v = repmat(v, numel(x), 1);
else
    v = v(:);
end
if numel(v) ~= numel(x)
    error('velocity must be scalar or one value per element.');
end

Array = kspaceDirec.local_base_array(x, y, v);
Array.src = 'circ';
Array.a = radius;
end
