function dom = estimateDomain(sourceType, varargin)
%ESTIMATEDOMAIN Estimate computational domain lengths.

ip = inputParser;
ip.addParameter('W', []);
ip.addParameter('H', []);
ip.addParameter('D', []);
ip.addParameter('f1', 40e3);
ip.addParameter('fa', 1e3);
ip.addParameter('c0', 343);
ip.addParameter('Cz', 70);
ip.addParameter('eta', 0.5);
ip.addParameter('steerDeg', 0);
ip.parse(varargin{:});
opt = ip.Results;

lambdaU = opt.c0 / opt.f1;
lambdaA = opt.c0 / opt.fa;
Lz = opt.Cz * lambdaA;

switch lower(string(sourceType))
    case "circ"
        D = opt.D;
        if isempty(D)
            error('Circular source requires D.');
        end
        Lx0 = D + 2 * opt.eta * Lz * lambdaU / D;
        Ly0 = Lx0;
    case "rect"
        W = opt.W;
        H = opt.H;
        if isempty(W) || isempty(H)
            error('Rectangular source requires W and H.');
        end
        Lx0 = W + 2 * opt.eta * Lz * lambdaU / W;
        Ly0 = H + 2 * opt.eta * Lz * lambdaU / H;
    otherwise
        error('sourceType must be circ or rect.');
end

Lx = Lx0 + 2 * Lz * abs(tand(opt.steerDeg));
Ly = Ly0;

dom = struct();
dom.Lx = Lx;
dom.Ly = Ly;
dom.Lz = Lz;
dom.Lxy_square = max(Lx, Ly);
dom.lambda_ultra = lambdaU;
dom.lambda_audio = lambdaA;
dom.Cz = opt.Cz;
dom.eta = opt.eta;
dom.steerDeg = opt.steerDeg;
end
