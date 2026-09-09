import { spawnSync } from 'node:child_process';
import { copyFileSync, mkdirSync, renameSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = fileURLToPath(new URL('../', import.meta.url));
const site = fileURLToPath(new URL('../../../', import.meta.url));
const python = process.env.PYTHON || 'python3';
const env = { ...process.env, PATH: `${dirname(process.execPath)}:${process.env.PATH || ''}` };

function run(command, args) {
  const result = spawnSync(command, args, { cwd: root, env, stdio: 'inherit' });
  if (result.error) throw result.error;
  if (result.status !== 0) process.exit(result.status || 1);
}

run(process.execPath, ['node_modules/vinext/dist/cli.js', 'build']);
run(python, ['scripts/export-standalone.py']);
run(python, ['scripts/check-original-copy.py']);
run(python, ['scripts/check-translations.py']);
run(process.execPath, ['scripts/check-language-runtime.mjs']);

// Replace the site copy only after every check has passed.
const target = join(site, 'docs/pitchdecks/NyctoType/index.html');
mkdirSync(dirname(target), { recursive: true });
copyFileSync(join(root, 'output/html/NyctoType-Pitch.html'), target + '.tmp');
renameSync(target + '.tmp', target);
console.log('Updated: ' + target);
