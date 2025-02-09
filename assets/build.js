import * as esbuild from 'esbuild'
import { createGenerator } from 'unocss'
import unoconfig from './uno.config.js'

const uno = createGenerator(unoconfig)

const unocssPlugin = {
  name: 'unocss',
  setup(build) {
    build.onLoad({ filter: /\.js$/ }, async (args) => {
      const { css } = await uno.generate(args.path)
      return {
        contents: css,
        loader: 'css'
      }
    })
  }
}

await esbuild.build({
  entryPoints: ['js/app.js'],
  bundle: true,
  outdir: '../priv/static/assets',
  plugins: [unocssPlugin],
  loader: {
    '.js': 'jsx'
  }
})
