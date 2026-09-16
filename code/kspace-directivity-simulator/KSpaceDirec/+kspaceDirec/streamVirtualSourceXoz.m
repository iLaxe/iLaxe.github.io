function [q_xz, x_grid, z_grid, delta_x, delta_z, info] = ...
    streamVirtualSourceXoz(Const, Wave, Pal, Grid, varargin)
%STREAMVIRTUALSOURCEXOZ Stream the ASA virtual source to the xOz plane.
%
% This is an xz-plane-only memory-reduced version of
% fun_PalPlaneSrc_kspace_q_ver2. It uses the same angular spectrum formula
% for p1 and p2, but processes z in chunks and immediately accumulates
%
%   q_xz(x,z) = integral q(x,y,z) dy.
%
% It avoids storing full p1(x,y,z), p2(x,y,z), and q(x,y,z).
%
% Output:
%   q_xz   : y-integrated virtual source, sorted as q_xz(ix, iz)
%   x_grid : monotonic x vector
%   z_grid : monotonic stitched z vector matching the old q convention

ip = inputParser;
ip.addParameter('nx', ceil(Grid.xmax/Grid.deltax/2)+1);
ip.addParameter('ny', ceil(Grid.ymax/Grid.deltay/2)+1);
ip.addParameter('nx_audio', ceil(Grid.deltax_audio/Grid.deltax));
ip.addParameter('ny_audio', ceil(Grid.deltay_audio/Grid.deltay));
ip.addParameter('nz', 2*ceil(Grid.zmax/Grid.deltaz/2));
ip.addParameter('z_chunk', 64);
ip.addParameter('memory_log_file', '');
parse(ip, varargin{:});
opt = ip.Results;

Grid.x = linspace(0, Grid.xmax/2, opt.nx).';
Grid.x = [Grid.x ; -flip(Grid.x(2:end))];
Grid.delta_x = Grid.x(2) - Grid.x(1);

Grid.y = linspace(0, Grid.ymax/2, opt.ny);
Grid.y = [Grid.y -flip(Grid.y(2:end))];
Grid.delta_y = Grid.y(2) - Grid.y(1);

z_tmp = linspace(-Grid.zmax/2, Grid.zmax/2, opt.nz);
z_tmp = reshape([z_tmp(opt.nz/2+1 : end) z_tmp(1 : opt.nz/2)], 1, 1, []);
delta_z = z_tmp(2) - z_tmp(1);
Grid.z = z_tmp(1 : opt.nz/2);
Grid.delta_z = delta_z;

Grid.kx = (0:(opt.nx-1)).' * (2*pi/Grid.xmax);
Grid.kx = [Grid.kx; -flip(Grid.kx(2:end))];

Grid.ky = (0:(opt.ny-1)) * (2*pi/Grid.ymax);
Grid.ky = [Grid.ky -flip(Grid.ky(2:end))];

idx_x_audio = (1:opt.nx_audio:opt.nx).';
idx_x_audio = [idx_x_audio; idx_x_audio(1:(end-1)) + opt.nx];
idx_y_audio = (1:opt.ny_audio:opt.ny).';
idx_y_audio = [idx_y_audio; idx_y_audio(1:(end-1)) + opt.ny];

x_unsorted = Grid.x(idx_x_audio);
y_unsorted = Grid.y(idx_y_audio);
delta_x_unsorted = x_unsorted(2) - x_unsorted(1);
delta_y = y_unsorted(2) - y_unsorted(1);

U1 = local_source_spectrum(Grid, Wave.ultra1, Pal.array1);
U2 = local_source_spectrum(Grid, Wave.ultra2, Pal.array2);

nx_out = numel(idx_x_audio);
nz_half = numel(Grid.z);
q_xz_half = zeros(nx_out, nz_half);
coef = Const.beta * Wave.audio.omega / (1i * Const.rho0^2 * Const.c0^4);

z_chunk = max(1, round(opt.z_chunk));
for i1 = 1:z_chunk:nz_half
    i2 = min(nz_half, i1 + z_chunk - 1);
    z_block = Grid.z(:, :, i1:i2);

    p1 = local_asa_pressure_block(Const, Grid, Wave.ultra1, U1, z_block);
    p2 = local_asa_pressure_block(Const, Grid, Wave.ultra2, U2, z_block);
    p1 = p1(idx_x_audio, idx_y_audio, :);
    p2 = p2(idx_x_audio, idx_y_audio, :);

    q_block = coef .* conj(p1) .* p2;
    q_xz_half(:, i1:i2) = squeeze(sum(q_block, 2)) * delta_y;

    clear p1 p2 q_block;
end

z_half = squeeze(Grid.z);
z_pair = [z_half(:).', z_half(:).' + z_half(1) + z_half(end)];
z_unsorted = [z_pair, -fliplr(z_pair)];
q_zero = zeros(size(q_xz_half), 'like', q_xz_half);
q_xz_unsorted = [q_xz_half, q_zero, q_zero, fliplr(q_xz_half)];

[x_grid, ix] = sort(x_unsorted(:), 'ascend');
[z_grid, iz] = sort(z_unsorted(:), 'ascend');
q_xz = q_xz_unsorted(ix, iz);

delta_x = median(diff(x_grid));
delta_z = median(diff(z_grid));

info = struct();
info.nx_full = numel(Grid.x);
info.ny_full = numel(Grid.y);
info.nz_half = nz_half;
info.idx_x_audio = idx_x_audio;
info.idx_y_audio = idx_y_audio;
info.delta_y = delta_y;
info.delta_x_unsorted = delta_x_unsorted;
info.z_chunk = z_chunk;
info.memory_log_file = opt.memory_log_file;
info.memory_note = 'q_xz only; full p1/p2/q are never stored across z.';
end

function U = local_source_spectrum(Grid, Ultra, Array)
k = Ultra.k;
switch Array.src
    case 'circ'
        kr = sqrt(Grid.kx.^2 + Grid.ky.^2);
        U0 = 2 * pi * Array.a * besselj(1, kr * Array.a) ./ kr;
        U0(kr == 0) = pi * Array.a^2;
        U = U0 .* exp(-1i * Grid.kx .* Array.x) .* ...
            exp(-1i * Grid.ky .* Array.y);
    case 'rec'
        Sinc_x = 2 * sin(Array.ax * Grid.kx) ./ Grid.kx;
        Sinc_x(Grid.kx == 0) = 2 * Array.ax;
        Sinc_y = 2 * sin(Array.ay * Grid.ky) ./ Grid.ky;
        Sinc_y(Grid.ky == 0) = 2 * Array.ay;
        U0 = Sinc_x .* Sinc_y;
        U = U0 .* exp(-1i * Grid.kx .* Array.x) .* ...
            exp(-1i * Grid.ky .* Array.y);
    case 'ideal_rec'
        theta = 30 / 180 * pi;
        Sinc_x = 2 * sin(Array.ax * (Grid.kx-k*sin(theta))) ./ (Grid.kx-k*sin(theta));
        Sinc_x(abs((Grid.kx-k*sin(theta))) < 1e-3) = 2 * Array.ax;
        Sinc_y = 2 * sin(Array.ay * Grid.ky) ./ Grid.ky;
        Sinc_y(Grid.ky == 0) = 2 * Array.ay;
        U0 = Sinc_x .* Sinc_y;
        U = U0 .* exp(-1i * Grid.kx .* Array.x) .* ...
            exp(-1i * Grid.ky .* Array.y);
    otherwise
        error("Select the source type!");
end

U = sum(U .* Array.v, 3) / Grid.delta_x / Grid.delta_y;
end

function prs = local_asa_pressure_block(Const, Grid, Ultra, U, z_block)
k = Ultra.k;
alpha = Ultra.alpha;
kz = sqrt(k^2 - Grid.kx.^2 - Grid.ky.^2);

F1_H = 2 * exp(1i * kz .* abs(z_block)) ./ kz;
S = exp(- alpha * k * abs(z_block) ./ kz);
F1_H = F1_H .* S;
F1_H = F1_H .* (sqrt(Grid.kx.^2 + Grid.ky.^2) < ...
    k * sqrt(Grid.xmax * Grid.ymax / 2 ./ (Grid.xmax * Grid.ymax / 2 + z_block.^2)));

prs = Const.rho0 * pi * Ultra.f * U .* F1_H;
prs = fillmissing(prs, 'constant', 0);
prs = ifft2(prs);
end
