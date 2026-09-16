function Const = defaultConst(varargin)
%DEFAULTCONST Default air and PAL constants.

ip = inputParser;
ip.addParameter('c0', 343);
ip.addParameter('rho0', 1.21);
ip.addParameter('beta', 1.2);
ip.addParameter('temp', 20);
ip.addParameter('humi', 70);
ip.addParameter('v0', 0.121);
ip.parse(varargin{:});
Const = ip.Results;
end
