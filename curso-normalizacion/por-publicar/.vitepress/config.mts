import { defineConfig } from 'vitepress'
import { withMermaid } from 'vitepress-plugin-mermaid'
import llmstxt, { copyOrDownloadAsMarkdownButtons } from 'vitepress-plugin-llms'
import { configureDiagramsPlugin } from 'vitepress-plugin-diagrams'
import { sidebar } from './sidebar.mts'

// Servido por IIS en https://preproddesa.campus.ua.es/curso-normalizacion/
const siteBase = '/curso-normalizacion/'

export default withMermaid(defineConfig({
  mermaid: {},
  lang: 'es-ES',
  base: siteBase,
  title: 'Curso Normalización',
  description: 'Material del curso de normalización de aplicaciones — 25 sesiones de Oracle, .NET y Vue.',
  srcExclude: ['**/* - copia.md', '**/node_modules/**', '**/README.md'],

  ignoreDeadLinks: true,

  vite: {
    plugins: [llmstxt()],
  },

  markdown: {
    lineNumbers: true,
    config: (md) => {
      md.use(copyOrDownloadAsMarkdownButtons)
      configureDiagramsPlugin(md, {
        diagramsDir: 'public/diagrams',
        publicPath: `${siteBase}diagrams`,
        krokiServerUrl: 'https://kroki.io',
        excludedDiagramTypes: ['mermaid'],
      })
    },
  },

  vue: {
    template: {
      compilerOptions: {
        isCustomElement: (tag) => /^[A-Z]/.test(tag) && tag.includes('-'),
      },
    },
  },

  themeConfig: {
    nav: [
      { text: 'Portada', link: '/' },
      { text: 'Organización', link: '/organizacion-del-curso' },
      { text: 'Oracle', link: '/01-oracle/' },
      { text: '.NET', link: '/02-dotnet/' },
      { text: 'Vue', link: '/03-vue/' },
      { text: 'Integración', link: '/04-integracion/' },
      { text: 'Avanzadas', link: '/05-avanzadas/' },
    ],

    outline: {
      label: 'En esta página',
      level: [2, 4],
    },

    search: {
      provider: 'local',
      options: {
        miniSearch: {
          searchOptions: {
            fuzzy: 0.2,
            prefix: true,
            boost: { title: 4, text: 2, titles: 1 },
          },
        },
      },
    },

    sidebar,

    docFooter: {
      prev: 'Anterior',
      next: 'Siguiente',
    },

    socialLinks: [],
  },
}))
