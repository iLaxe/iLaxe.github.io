# KSpaceDirec

MATLAB implementation of the observable-oriented k-space-shell solver for
multi-channel parametric array loudspeakers (PALs).

The simulator follows the workflow described in:

> X. Wu, S.-Z. Li, M. Li, and J.-X. Zhong, "A K-Space Directivity Solver
> for Multi-Channel Parametric Array Loudspeakers," submitted to ICASSP 2027.

## Features

- Circular, rectangular, and 32-channel staggered PAL source builders.
- Independent carrier and sideband steering.
- Block-wise propagation that avoids storing full 3-D pressure volumes.
- Observable-oriented reduction to the xOz plane.
- Far-field directivity evaluation on the audio k-space shell.
- Direct-summation fallback when MATLAB's `nufftn` is unavailable.

## Requirements

- MATLAB R2021b or later is recommended.
- No external project folders are required.
- `nufftn` is optional. Without it, the simulator automatically uses direct
  spatial-spectrum evaluation.

The large examples can require substantial memory and runtime. Start with the
single-source example before increasing the computational domain.

## Quick start

Open MATLAB in the `KSpaceDirec` directory and run:

```matlab
addpath(pwd);
run('examples/demo_single_circular.m');
```

Minimal programmatic use:

```matlab
Const = kspaceDirec.defaultConst();
Wave = kspaceDirec.makeWave(40e3, 41e3, Const);
Array = kspaceDirec.makeCircularArray(0.005, Const.v0);
Grid = kspaceDirec.defaultGrid( ...
    'Lx', 0.32, 'Ly', 0.32, 'Lz', 24, ...
    'dxAudio', 0.01, 'dyAudio', 0.01, 'dz', 0.005);

theta = (-80:1:80).';
result = kspaceDirec.runXoz( ...
    Const, Wave, Array, Array, Grid, theta, ...
    'zChunk', 64, 'keepQxz', false);

plot(result.theta_deg, result.dir_db);
xlabel('Angle (deg)');
ylabel('Normalized level (dB)');
```

## Examples

- `examples/demo_single_circular.m`: single circular PAL source.
- `examples/demo_rectangular_domain_estimate.m`: first-pass domain sizing.
- `examples/demo_32ch_steered_array.m`: 32-channel steered PAL array.

## Main interfaces

### Simulation

- `kspaceDirec.runXoz(...)`: run the complete streaming xOz-plane solver.
- `kspaceDirec.streamVirtualSourceXoz(...)`: construct the y-integrated
  virtual source using block-wise propagation.
- `kspaceDirec.farfieldXoz(...)`: evaluate far-field directivity from a
  precomputed xOz virtual-source distribution.

### Configuration

- `kspaceDirec.defaultConst(...)`: define air and PAL constants.
- `kspaceDirec.makeWave(f1, f2, Const)`: construct carrier, sideband, and
  difference-frequency parameters.
- `kspaceDirec.defaultGrid(...)`: define the computational grid.
- `kspaceDirec.estimateDomain(...)`: estimate initial domain dimensions.

### Source construction

- `kspaceDirec.makeCircularArray(radius, velocity, ...)`
- `kspaceDirec.makeRectArray(width, height, velocity, ...)`
- `kspaceDirec.makeColumnArray32x6(...)`
- `kspaceDirec.applySteering(Array, k, thetaDeg, ...)`

## Output

`kspaceDirec.runXoz` returns a structure containing:

- `theta_deg`: observation angles.
- `directivity`: complex far-field response.
- `amplitude` and `amplitude_normalized`: response magnitudes.
- `dir_db`: normalized directivity in decibels.
- `runtime_source_s`, `runtime_farfield_s`, and `runtime_total_s`.
- `grid`, `info`, and `source_summary`.
- `qxz`, `x`, and `z` when `keepQxz` is set to `true`.

## Notes

The code evaluates directivity in the xOz observation plane. Grid lengths are
full physical lengths; the propagation region uses x in `[-Lx/2, Lx/2]`, y
in `[-Ly/2, Ly/2]`, and positive z propagation before symmetric extension.

Please cite the associated paper when using this simulator in academic work.
