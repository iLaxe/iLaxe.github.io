function out = farfieldXoz(qxz, x, z, dx, dz, ka, thetaDeg, varargin)
%FARFIELDXOZ Evaluate xOz-plane far-field directivity from qxz.

ip = inputParser;
ip.addParameter('method', 'auto');
ip.addParameter('normalize', true);
ip.addParameter('thetaChunk', 64);
ip.parse(varargin{:});
opt = ip.Results;

method = lower(string(opt.method));
if method == "auto"
    if exist('nufftn', 'file') == 2
        method = "nufft";
    else
        method = "direct";
    end
end

thetaDeg = thetaDeg(:);
switch method
    case "nufft"
        F = ka * [sind(thetaDeg), cosd(thetaDeg)] / (2*pi);
        D = nufftn(qxz, {x(:), z(:)}, F) * dx * dz;
    case "direct"
        D = local_direct_sum(qxz, x(:), z(:), dx, dz, ka, thetaDeg, opt.thetaChunk);
    otherwise
        error('Unknown farfield method: %s', method);
end

amp = abs(D);
if opt.normalize
    amp_norm = amp ./ max(max(amp), eps);
else
    amp_norm = amp;
end

out = struct();
out.theta_deg = thetaDeg;
out.D = D;
out.amp_norm = amp_norm;
out.dir_db = 20 * log10(max(amp_norm, eps));
out.method = char(method);
end

function D = local_direct_sum(qxz, x, z, dx, dz, ka, thetaDeg, thetaChunk)
[X, Z] = ndgrid(x, z);
qv = qxz(:);
xv = X(:);
zv = Z(:);
D = zeros(numel(thetaDeg), 1);
thetaChunk = max(1, round(thetaChunk));
for i1 = 1:thetaChunk:numel(thetaDeg)
    i2 = min(numel(thetaDeg), i1 + thetaChunk - 1);
    th = thetaDeg(i1:i2).';
    phase = ka * (xv * sind(th) + zv * cosd(th));
    D(i1:i2) = (qv.' * exp(-1i * phase)).' * dx * dz;
end
end
