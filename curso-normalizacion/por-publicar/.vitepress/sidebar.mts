import { readFileSync, readdirSync, statSync, existsSync } from 'node:fs'
import { join, resolve } from 'node:path'
import matter from 'gray-matter'

// Raiz del sitio = carpeta padre de .vitepress
const srcRoot = resolve(__dirname, '..')

type SidebarItem = {
  text: string
  link?: string
  collapsed?: boolean
  items?: SidebarItem[]
}

type SidebarEntry = { path: string }

// Lee _sidebar.json de una carpeta. Devuelve null si no existe.
function leerSidebarJson(dir: string): SidebarEntry[] | { visible: boolean } | null {
  const ruta = join(dir, '_sidebar.json')
  if (!existsSync(ruta)) return null
  try {
    return JSON.parse(readFileSync(ruta, 'utf8'))
  } catch {
    return null
  }
}

// Lee el title del frontmatter del index.md de una carpeta.
// Si no hay frontmatter o el index no existe, cae al nombre de la carpeta.
function titulo(dir: string, fallback: string): string {
  const indexPath = join(dir, 'index.md')
  if (existsSync(indexPath)) {
    const { data } = matter(readFileSync(indexPath, 'utf8'))
    if (typeof data.title === 'string' && data.title.trim().length > 0) {
      return data.title.trim()
    }
  }
  return fallback
}

// Convierte una ruta absoluta a un link VitePress relativo a srcRoot.
// Formato esperado: /sub/dir/  (con slashes y sin index.md)
function aLink(dirAbs: string): string {
  const rel = dirAbs.substring(srcRoot.length).replaceAll('\\', '/')
  const conSlash = rel.endsWith('/') ? rel : rel + '/'
  return conSlash || '/'
}

// Devuelve la lista de subcarpetas (no _ ni . ni node_modules).
function subcarpetas(dir: string): string[] {
  return readdirSync(dir)
    .filter((nombre) => {
      if (nombre.startsWith('.') || nombre.startsWith('_')) return false
      if (nombre === 'node_modules' || nombre === 'public') return false
      const stat = statSync(join(dir, nombre))
      return stat.isDirectory()
    })
    .sort()
}

// Construye recursivamente los items para una carpeta de seccion.
// Si la carpeta tiene index.md, se anyade como primer item "Indice".
function construirItems(dir: string): SidebarItem[] {
  const items: SidebarItem[] = []

  if (existsSync(join(dir, 'index.md'))) {
    items.push({ text: 'Índice', link: aLink(dir) })
  }

  for (const sub of subcarpetas(dir)) {
    const subAbs = join(dir, sub)
    const sidebarHijo = leerSidebarJson(subAbs)

    // Si el hijo dice {"visible": false} igualmente lo mostramos
    // en el sitio STANDALONE: aqui no estamos integrandonos en un sidebar global.
    // (Esa bandera la usa el sitio grande para ocultarse de su navegacion.)
    const texto = titulo(subAbs, sub)

    // Subcarpetas de un nivel mas profundo (p.ej. sesiones/sesion-04-...)
    const subSub = subcarpetas(subAbs)
    if (subSub.length > 0) {
      items.push({
        text: texto,
        collapsed: true,
        items: construirItems(subAbs),
      })
    } else {
      items.push({ text: texto, link: aLink(subAbs) })
    }
  }

  return items
}

// Lee el _sidebar.json de la raiz y construye el sidebar completo.
// El sidebar es el MISMO para todas las rutas: el sitio del curso es una
// experiencia lineal de principio a fin.
function construirSidebar(): SidebarItem[] {
  const root = srcRoot
  const config = leerSidebarJson(root)
  if (!config || !Array.isArray(config)) {
    return construirItems(root)
  }

  const items: SidebarItem[] = [
    { text: 'Portada del curso', link: '/' },
  ]

  for (const entrada of config) {
    const subAbs = join(root, entrada.path)
    if (!existsSync(subAbs)) continue

    const texto = titulo(subAbs, entrada.path.replace(/\/$/, ''))
    items.push({
      text: texto,
      collapsed: true,
      items: construirItems(subAbs),
    })
  }

  return items
}

export const sidebar = construirSidebar()
