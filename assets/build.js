import * as esbuild from 'esbuild'

await esbuild.build({
  entryPoints: ['js/app.js'],
  bundle: true,
  outdir: '../priv/static/assets',
  plugins: [cssPlugin],
  loader: {
    '.js': 'jsx',
    '.css': 'css',
  },
})
