import { defineConfig, presetUno, presetWebFonts, presetIcons, transformerVariantGroup } from 'unocss'

export default defineConfig({
  presets: [
    presetUno(),
    presetWebFonts({
      provider: 'google',
      fonts: {
        sans: 'Inter:400,500,600,700',
        mono: 'JetBrains Mono:400,500'
      }
    }),
    presetIcons({
      scale: 1.2,
      cdn: 'https://esm.sh/'
    })
  ],
  transformers: [
    transformerVariantGroup()
  ],
  theme: {
    colors: {
      primary: 'var(--color-primary)',
      secondary: 'var(--color-secondary)',
      accent: 'var(--color-accent)',
      background: 'var(--color-background)',
      surface: 'var(--color-surface)',
      border: 'var(--color-border)'
    },
    container: {
      center: true,
      padding: '2rem'
    }
  },
  shortcuts: {
    'btn': 'px4 py2 rounded-lg bg-primary text-white hover:bg-secondary transition-colors',
    'input': 'px3 py2 rounded-lg bg-surface border-border focus:outline-none focus:border-primary',
    'card': 'bg-surface border-border rounded-xl p4'
  }
})
