function result = runXoz(Const, Wave, Array1, Array2, Grid, thetaDeg, varargin)
%RUNXOZ Run the xOz-plane streaming k-space directivity simulator.

ip = inputParser;
ip.addParameter('zChunk', 64);
ip.addParameter('keepQxz', false);
ip.addParameter('memoryLogFile', '');
ip.addParameter('farfieldMethod', 'auto');
ip.parse(varargin{:});
opt = ip.Results;

Pal.array1 = Array1;
Pal.array2 = Array2;

t0 = tic;
[qxz, x, z, dx, dz, info] = kspaceDirec.streamVirtualSourceXoz( ...
    Const, Wave, Pal, Grid, 'z_chunk', opt.zChunk, ...
    'memory_log_file', opt.memoryLogFile);
t_source = toc(t0);

t0 = tic;
ff = kspaceDirec.farfieldXoz(qxz, x, z, dx, dz, Wave.audio.k, thetaDeg, ...
    'method', opt.farfieldMethod);
t_farfield = toc(t0);

result = ff;
result.runtime_source_s = t_source;
result.runtime_farfield_s = t_farfield;
result.runtime_total_s = t_source + t_farfield;
result.grid = Grid;
result.info = info;
result.source_summary = local_source_summary(Array1, Array2);
if opt.keepQxz
    result.qxz = qxz;
    result.x = x;
    result.z = z;
end
end

function s = local_source_summary(Array1, Array2)
s = struct();
s.num1 = Array1.num;
s.num2 = Array2.num;
s.src1 = Array1.src;
s.src2 = Array2.src;
end
