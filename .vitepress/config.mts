import { defineConfig } from 'vitepress'
import { withMermaid } from 'vitepress-mermaid'
import llmstxt, { copyOrDownloadAsMarkdownButtons } from 'vitepress-plugin-llms'
import { generatedSidebar } from './generated-sidebar.mts'
import { configureDiagramsPlugin } from "vitepress-plugin-diagrams";

const siteBase = normalizeBase(process.env.VITEPRESS_BASE ?? '/docu-aplicaciones/')

function normalizeBase(value: string) {
  const trimmed = value.trim()
  if (trimmed === '' || trimmed === '/') {
    return '/'
  }

  return `/${trimmed.replace(/^\/+|\/+$/g, '')}/`
}

// https://vitepress.dev/reference/site-config
export default withMermaid(defineConfig({
  mermaid: {},
  lang: 'es-ES',
  srcDir: '.',
  srcExclude: [
    '**/* - copia.md',
    '**/*_old/**',
    '.vitepress/**',
    'node_modules/**',
    'scripts/**',
    'curso-normalizacion/*.md',
    'curso-normalizacion/en-codigo/**',
    'curso-normalizacion/SQL/**',
    'curso-normalizacion/por-publicar/parte-oracle/SQL/**',
    'curso-normalizacion/curso-bienvenida/**',
  ],
  rewrites: (id) => {
    if (id === 'curso-normalizacion/por-publicar/index.md') {
      return 'curso-normalizacion/index.md'
    }

    if (id.startsWith('curso-normalizacion/por-publicar/')) {
      return id.replace('curso-normalizacion/por-publicar/', 'curso-normalizacion/')
    }

    return id
  },
  base: siteBase,
  title: "Cursos de aplicaciones - Universidad de Alicante",
  description: "Cursos de formación para el personal del Servicio de Informática de la Universidad de Alicante",

  // Plugins
  vite: {
    plugins: [llmstxt()],
  },
  // Ignorar dead links que están en construcción
  ignoreDeadLinks: true,

  // Configuración de Markdown
  markdown: {
    lineNumbers: true,  // Mostrar números de línea en código
    config: (md) => {
      md.use(copyOrDownloadAsMarkdownButtons)
      configureDiagramsPlugin(md, {
        diagramsDir: "curso-normalizacion/por-publicar/public/diagrams",
        publicPath: "/diagrams",
        krokiServerUrl: "https://kroki.io",
        excludedDiagramTypes: ["mermaid"],
      });
    }
  },

  // Configuración de Vue
  vue: {
    template: {
      compilerOptions: {
        isCustomElement: (tag) => /^[A-Z]/.test(tag) && tag.includes('-')
      }
    }
  },

  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    siteTitle: 'Cursos 2026',

    nav: [
      { text: 'Inicio', link: '/' },
      { text: 'Curso Bienvenida', link: '/curso-bienvenida/' },
      { text: 'Curso Normalización', link: '/curso-normalizacion/' },
    ],

    // Etiqueta del índice lateral
    outline: {
      label: 'En esta página',
      level: [2, 2]
    },

    // Búsqueda local (incluida de forma nativa en VitePress)
    search: {
      provider: 'local',
      options: {
        miniSearch: {
          searchOptions: {
            fuzzy: 0.2,
            prefix: true,
            boost: { title: 4, text: 2, titles: 1 }
          }
        }
      }
    },

    sidebar: generatedSidebar
  }
}))
