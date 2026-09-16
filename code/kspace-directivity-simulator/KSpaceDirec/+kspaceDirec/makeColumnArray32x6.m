function Array = makeColumnArray32x6(varargin)
%MAKECOLUMNARRAY32X6 Build the 32-channel staggered PAL array.
%
% Each channel corresponds to one distinct x-coordinate column and contains
% six circular elements.

ip = inputParser;
ip.addParameter('radius', 0.005);
ip.addParameter('velocity', 0.121);
ip.addParameter('centered', true);
ip.parse(varargin{:});
opt = ip.Results;

Nch = 32;
NyPerChannel = 6;
r = opt.radius;
NxPhys = Nch / 2;
NyPhys = 2 * NyPerChannel;
dx = 2 * r;
dy = sqrt(3) * r;

xCols = (0:NxPhys-1) * dx;
yRows = (0:NyPhys-1) * dy;
[X, Y] = meshgrid(xCols, yRows);
rowShift = zeros(NyPhys, 1);
rowShift(2:2:end) = r;
X = X + rowShift;

if opt.centered
    X = X - mean(X(:));
    Y = Y - mean(Y(:));
end

chan = zeros(NyPhys, NxPhys);
for iy = 1:NyPhys
    for ix = 1:NxPhys
        if mod(iy, 2) == 1
            chan(iy, ix) = 2 * ix - 1;
        else
            chan(iy, ix) = 2 * ix;
        end
    end
end

Array = kspaceDirec.local_base_array(X(:), Y(:), opt.velocity);
Array.src = 'circ';
Array.a = r;
Array.Nx = NxPhys;
Array.Ny = NyPhys;
Array.NyPerChannel = NyPerChannel;
Array.Nch = Nch;
Array.chan_id = chan(:);
Array.Nk_list = ones(Nch, 1) * NyPerChannel;
Array.row_id = repelem((1:NyPhys).', NxPhys);
Array.col_id = repmat((1:NxPhys).', NyPhys, 1);
Array.dx = dx;
Array.dy = dy;
Array.aperture_x = max(X(:)) - min(X(:)) + 2 * r;
Array.aperture_y = max(Y(:)) - min(Y(:)) + 2 * r;
end
