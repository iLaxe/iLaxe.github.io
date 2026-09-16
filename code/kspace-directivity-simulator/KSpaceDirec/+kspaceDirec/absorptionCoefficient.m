function [alphaNp, alphaDb] = absorptionCoefficient(freq, varargin)
%ABSORPTIONCOEFFICIENT Atmospheric absorption following ISO 9613-1.
%
% alphaNp is returned in Np/m and alphaDb in dB/m.

ip = inputParser;
ip.addParameter('temperature', 20);
ip.addParameter('pressure', 101.325);
ip.addParameter('humidity', 70);
ip.parse(varargin{:});
opt = ip.Results;

T0 = 293.15;
T01 = 273.16;
T = opt.temperature + 273.15;
pr = 101.325;

C = -6.8346 * (T01 ./ T).^1.261 + 4.6151;
psat = pr .* 10.^C;
h = opt.humidity .* (psat ./ pr) .* (opt.pressure ./ pr);

frO = opt.pressure ./ pr .* (24 + 4.04e4 .* h .* (0.02 + h) ./ (0.391 + h));
frN = opt.pressure ./ pr .* (T ./ T0).^(-1/2) .* ...
    (9 + 280 .* h .* exp(-4.17 .* ((T ./ T0).^(-1/3) - 1)));

alphaNp = freq.^2 .* (1.84e-11 .* pr ./ opt.pressure .* (T ./ T0).^(1/2) + ...
    (T ./ T0).^(-5/2) .* (0.01275 .* exp(-2239.1 ./ T) ./ ...
    (frO + freq.^2 ./ frO) + 0.1068 .* exp(-3352.0 ./ T) ./ ...
    (frN + freq.^2 ./ frN)));
alphaDb = 20 / log(10) .* alphaNp;
end
