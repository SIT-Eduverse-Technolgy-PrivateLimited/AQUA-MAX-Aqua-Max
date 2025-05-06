import { build } from 'esbuild';
import glob from 'glob';

const entryPoints = glob.sync('./lambdas/**/*.ts');

build({
  entryPoints,
  outdir: 'dist/lambdas',
  bundle: true,
  platform: 'node',
  target: ['node18'],
  sourcemap: true,
  format: 'esm',
}).catch(() => process.exit(1));