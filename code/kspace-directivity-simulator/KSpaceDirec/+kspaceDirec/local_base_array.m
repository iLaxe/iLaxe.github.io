function Array = local_base_array(x, y, v)
%LOCAL_BASE_ARRAY Internal array struct constructor.

x = x(:);
y = y(:);
if isscalar(y) && numel(x) > 1
    y = repmat(y, numel(x), 1);
end
if isscalar(v) && numel(x) > 1
    v = repmat(v, numel(x), 1);
end
v = v(:);

if numel(x) ~= numel(y) || numel(x) ~= numel(v)
    error('x, y, and v must have compatible lengths.');
end

Array = struct();
Array.num = numel(x);
Array.Nx = numel(x);
Array.Ny = 1;
Array.Nch = numel(x);
Array.ch = (1:numel(x)).';
Array.chan_id = (1:numel(x)).';
Array.Nk_list = ones(numel(x), 1);
Array.row_id = ones(numel(x), 1);
Array.col_id = (1:numel(x)).';
Array.x = reshape(x, 1, 1, []);
Array.y = reshape(y, 1, 1, []);
Array.v = reshape(v, 1, 1, []);
end
