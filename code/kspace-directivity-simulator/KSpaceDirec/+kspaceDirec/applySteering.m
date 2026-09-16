function ArrayOut = applySteering(ArrayIn, k, thetaDeg, varargin)
%APPLYSTEERING Apply xOz-plane phase-gradient steering to an array.

ip = inputParser;
ip.addParameter('amplitude', []);
ip.addParameter('sign', 1);
ip.parse(varargin{:});
opt = ip.Results;

ArrayOut = ArrayIn;
x = squeeze(ArrayIn.x);
x = x(:);
if isempty(opt.amplitude)
    amp = abs(squeeze(ArrayIn.v));
else
    amp = opt.amplitude;
end
if isscalar(amp)
    amp = repmat(amp, numel(x), 1);
else
    amp = amp(:);
end
ArrayOut.v = reshape(amp .* exp(1i * opt.sign * k * x * sind(thetaDeg)), 1, 1, []);
end
