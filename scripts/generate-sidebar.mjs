import { promises as fs } from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'

const scriptDir = path.dirname(fileURLToPath(import.meta.url))
const rootDir = path.resolve(scriptDir, '..')
const outputFile = path.join(rootDir, '.vitepress', 'generated-sidebar.mts')
const indexLabel = 'Indice'

const courses = [
  {
    slug: 'curso-bienvenida',
    title: 'Curso Bienvenida',
    docsRoot: 'curso-bienvenida',
  },
  {
    slug: 'curso-normalizacion',
    title: 'Curso Normalizacion',
    docsRoot: 'curso-normalizacion/por-publicar',
  },
]

const excludedDirectoryNames = new Set([
  '.git',
  '.vitepress',
  'node_modules',
  'scripts',
  'public',
  'SQL',
  'en-codigo',
  'images',
  'img',
  'assets',
])

// Carpetas que aparecen en una ruta independiente del sidebar principal.
// El sidebar principal del curso las omite; el sidebar bajo esa ruta las
// agrupa en su propia clave (p. ej. '/curso-normalizacion/profesor/').
const isolatedSidebars = [
  {
    // Todo lo que cuelgue de profesor/ y todas las carpetas guia-profesor/
    // anidadas en cualquier nivel se aislan bajo /<curso>/profesor/.
    routeKey: 'profesor',
    matchTopLevelName: 'profesor',
    matchNestedName: 'guia-profesor',
  },
]

const excludedFileNames = new Set(['README.md'])

function normalizeDocPath(relativePath) {
  return relativePath.replace(/\\/g, '/')
}

function yamlValue(rawValue) {
  const trimmed = rawValue.trim()

  if (
    (trimmed.startsWith('"') && trimmed.endsWith('"')) ||
    (trimmed.startsWith("'") && trimmed.endsWith("'"))
  ) {
    return trimmed.slice(1, -1)
  }

  return trimmed
}

function prettyText(value) {
  const normalized = value.replace(/[-_]+/g, ' ').trim()

  if (!normalized) {
    return value
  }

  return normalized
    .split(/\s+/)
    .map((word) => {
      if (word.toUpperCase() === word) {
        return word
      }

      return word.charAt(0).toUpperCase() + word.slice(1)
    })
    .join(' ')
}

function routeFromCourseDoc(course, relativePath) {
  const normalizedPath = normalizeDocPath(relativePath)
  const routePrefix = `/${course.slug}`

  if (normalizedPath === 'index.md' || normalizedPath === 'README.md') {
    return `${routePrefix}/`
  }

  if (normalizedPath.endsWith('/index.md') || normalizedPath.endsWith('/README.md')) {
    return `${routePrefix}/${normalizedPath.replace(/\/(?:index|README)\.md$/u, '')}/`
  }

  return `${routePrefix}/${normalizedPath.replace(/\.md$/u, '')}`
}

async function fileExists(filePath) {
  try {
    await fs.access(filePath)
    return true
  } catch {
    return false
  }
}

async function readTitleFromFile(filePath, fallbackText) {
  const content = await fs.readFile(filePath, 'utf8')

  const frontmatterMatch = content.match(/^---\r?\n([\s\S]*?)\r?\n---/u)
  if (frontmatterMatch) {
    const titleMatch = frontmatterMatch[1].match(/^\s*title\s*:\s*(.+)\s*$/mu)
    if (titleMatch) {
      return yamlValue(titleMatch[1])
    }
  }

  const headingMatch = content.match(/^#\s+(.+)\s*$/mu)
  if (headingMatch) {
    return headingMatch[1].trim()
  }

  return fallbackText
}

async function readCourseTitle(course, relativePath, fallbackText) {
  const filePath = path.join(rootDir, course.docsRoot, relativePath)
  return readTitleFromFile(filePath, fallbackText ?? prettyText(path.basename(relativePath, '.md')))
}

function indexItem(link) {
  return {
    text: indexLabel,
    link,
  }
}

function sessionNumberFromPath(relativePath) {
  const normalizedPath = normalizeDocPath(relativePath)
  const match = normalizedPath.match(/sesion-(\d+)/u)

  if (!match) {
    return Number.POSITIVE_INFINITY
  }

  return Number(match[1])
}

function sortEntriesByName(left, right) {
  const leftSession = sessionNumberFromPath(left.name)
  const rightSession = sessionNumberFromPath(right.name)

  if (leftSession !== rightSession) {
    return leftSession - rightSession
  }

  return left.name.localeCompare(right.name, 'es')
}

function shouldSkipDirectory(entry) {
  return (
    excludedDirectoryNames.has(entry.name) ||
    entry.name.endsWith('_old') ||
    entry.name.startsWith('.')
  )
}

function isIsolatedDirectoryName(name) {
  return isolatedSidebars.some(
    (cfg) => cfg.matchTopLevelName === name || cfg.matchNestedName === name
  )
}

function shouldSkipForMainSidebar(entry) {
  return shouldSkipDirectory(entry) || isIsolatedDirectoryName(entry.name)
}

function shouldSkipFile(entry) {
  return (
    excludedFileNames.has(entry.name) ||
    entry.name.endsWith(' - copia.md') ||
    !/\.md$/iu.test(entry.name)
  )
}

async function readDirEntries(directoryPath) {
  try {
    return await fs.readdir(directoryPath, { withFileTypes: true })
  } catch {
    return []
  }
}

async function buildFileItem(course, relativePath) {
  return {
    text: await readCourseTitle(course, relativePath),
    link: routeFromCourseDoc(course, relativePath),
  }
}

async function readSidebarConfig(course, relativeDir) {
  const configPath = path.join(rootDir, course.docsRoot, relativeDir, '_sidebar.json')
  if (!(await fileExists(configPath))) {
    return null
  }
  const content = await fs.readFile(configPath, 'utf8')
  if (!content.trim()) {
    return null
  }
  return JSON.parse(content)
}

function isConfigHidden(config) {
  if (!config || Array.isArray(config) || typeof config !== 'object') {
    return false
  }
  return config.visible === false
}

function isEntryHidden(entry) {
  if (!entry || typeof entry !== 'object' || Array.isArray(entry)) {
    return false
  }
  return entry.visible === false
}

function configEntries(config) {
  if (!config) return null
  if (Array.isArray(config)) return config
  if (Array.isArray(config.items)) return config.items
  return []
}

async function isLeafDirectory(course, relativeDir) {
  const absoluteDir = path.join(rootDir, course.docsRoot, relativeDir)
  const entries = await readDirEntries(absoluteDir)
  const hasSubdir = entries.some((e) => e.isDirectory() && !shouldSkipDirectory(e))
  const hasOtherMd = entries.some(
    (e) => e.isFile() && !shouldSkipFile(e) && !/^(index|README)\.md$/iu.test(e.name)
  )
  if (hasSubdir || hasOtherMd) return false
  const indexFilePath = path.join(absoluteDir, 'index.md')
  const readmeFilePath = path.join(absoluteDir, 'README.md')
  return (await fileExists(indexFilePath)) || (await fileExists(readmeFilePath))
}

async function buildDirectoryItems(course, relativeDir, options = {}) {
  const { excludeIsolated = false } = options
  const absoluteDir = path.join(rootDir, course.docsRoot, relativeDir)
  const entries = await readDirEntries(absoluteDir)
  const directoryFilter = excludeIsolated ? shouldSkipForMainSidebar : shouldSkipDirectory
  const directories = entries
    .filter((entry) => entry.isDirectory() && !directoryFilter(entry))
    .sort(sortEntriesByName)
  const files = entries
    .filter((entry) => entry.isFile() && !shouldSkipFile(entry) && !/^(index|README)\.md$/iu.test(entry.name))
    .sort(sortEntriesByName)

  const items = []

  for (const directory of directories) {
    const childRelativeDir = normalizeDocPath(path.posix.join(normalizeDocPath(relativeDir), directory.name))
    const indexRelativePath = `${childRelativeDir}/index.md`
    const readmeRelativePath = `${childRelativeDir}/README.md`
    const indexFilePath = path.join(rootDir, course.docsRoot, indexRelativePath)
    const readmeFilePath = path.join(rootDir, course.docsRoot, readmeRelativePath)

    const childConfig = await readSidebarConfig(course, childRelativeDir)
    if (isConfigHidden(childConfig)) {
      const childIndexRel = (await fileExists(indexFilePath)) ? indexRelativePath : readmeRelativePath
      if (await fileExists(path.join(rootDir, course.docsRoot, childIndexRel))) {
        items.push({
          text: await readCourseTitle(course, childIndexRel, prettyText(directory.name)),
          link: routeFromCourseDoc(course, childIndexRel),
        })
      }
      continue
    }

    const leaf = await isLeafDirectory(course, childRelativeDir)
    if (leaf) {
      const leafIndexRel = (await fileExists(indexFilePath)) ? indexRelativePath : readmeRelativePath
      items.push({
        text: await readCourseTitle(course, leafIndexRel, prettyText(directory.name)),
        link: routeFromCourseDoc(course, leafIndexRel),
      })
      continue
    }

    const childItems = await buildDirectoryItems(course, childRelativeDir, options)

    if (await fileExists(indexFilePath)) {
      items.push({
        text: await readCourseTitle(course, indexRelativePath, prettyText(directory.name)),
        collapsed: true,
        items: [
          indexItem(routeFromCourseDoc(course, indexRelativePath)),
          ...childItems,
        ],
      })
      continue
    }

    if (await fileExists(readmeFilePath)) {
      items.push({
        text: await readCourseTitle(course, readmeRelativePath, prettyText(directory.name)),
        collapsed: true,
        items: [
          indexItem(routeFromCourseDoc(course, readmeRelativePath)),
          ...childItems,
        ],
      })
      continue
    }

    if (childItems.length > 0) {
      items.push({
        text: prettyText(directory.name),
        collapsed: true,
        items: childItems,
      })
    }
  }

  for (const file of files) {
    const fileRelativePath = normalizeDocPath(path.posix.join(normalizeDocPath(relativeDir), file.name))
    items.push(await buildFileItem(course, fileRelativePath))
  }

  return items
}

async function buildCourseSidebar(course) {
  const courseRoot = path.join(rootDir, course.docsRoot)
  const rootIndexPath = path.join(courseRoot, 'index.md')
  const rootReadmePath = path.join(courseRoot, 'README.md')
  const rootRelativePath = await fileExists(rootIndexPath) ? 'index.md' : 'README.md'
  const rootFilePath = await fileExists(rootIndexPath) ? rootIndexPath : rootReadmePath
  const rootTitle = await readTitleFromFile(rootFilePath, course.title)
  const childItems = await buildDirectoryItems(course, '', { excludeIsolated: true })

  return [
    {
      text: rootTitle,
      items: [
        indexItem(routeFromCourseDoc(course, rootRelativePath)),
        ...childItems,
      ],
    },
  ]
}

async function findIsolatedDirs(course, relativeDir, isolatedConfig, depth = 0) {
  const absoluteDir = path.join(rootDir, course.docsRoot, relativeDir)
  const entries = await readDirEntries(absoluteDir)
  const matches = []

  for (const entry of entries) {
    if (!entry.isDirectory() || shouldSkipDirectory(entry)) {
      continue
    }

    const childRelativeDir = relativeDir
      ? normalizeDocPath(path.posix.join(normalizeDocPath(relativeDir), entry.name))
      : entry.name
    const isTopLevelMatch = depth === 0 && entry.name === isolatedConfig.matchTopLevelName
    const isNestedMatch = depth > 0 && entry.name === isolatedConfig.matchNestedName

    if (isTopLevelMatch || isNestedMatch) {
      matches.push(childRelativeDir)
      continue
    }

    matches.push(...(await findIsolatedDirs(course, childRelativeDir, isolatedConfig, depth + 1)))
  }

  return matches
}

async function buildIsolatedSection(course, relativeDir) {
  const indexRelativePath = `${relativeDir}/index.md`
  const indexFilePath = path.join(rootDir, course.docsRoot, indexRelativePath)
  const sectionTitle = await readCourseTitle(
    course,
    indexRelativePath,
    prettyText(relativeDir.split('/').filter(Boolean).pop() ?? relativeDir)
  )
  const childItems = await buildDirectoryItems(course, relativeDir)

  const items = []
  if (await fileExists(indexFilePath)) {
    items.push(indexItem(routeFromCourseDoc(course, indexRelativePath)))
  }
  items.push(...childItems)

  return {
    text: sectionTitle,
    items,
  }
}

async function buildIsolatedSidebar(course, isolatedConfig) {
  const isolatedDirs = await findIsolatedDirs(course, '', isolatedConfig)
  if (isolatedDirs.length === 0) {
    return null
  }

  const sections = []
  for (const isolatedDir of isolatedDirs.sort()) {
    sections.push(await buildIsolatedSection(course, isolatedDir))
  }

  return sections
}

async function main() {
  const generatedSidebar = {
    '/': [
      {
        text: 'Cursos 2026',
        items: courses.map((course) => ({
          text: course.title,
          link: `/${course.slug}/`,
        })),
      },
    ],
  }

  for (const course of courses) {
    generatedSidebar[`/${course.slug}/`] = await buildCourseSidebar(course)

    for (const isolatedConfig of isolatedSidebars) {
      const sidebar = await buildIsolatedSidebar(course, isolatedConfig)
      if (sidebar) {
        generatedSidebar[`/${course.slug}/${isolatedConfig.routeKey}/`] = sidebar
      }
    }
  }

  const fileContent = `// Archivo generado automaticamente por scripts/generate-sidebar.mjs
// No editar manualmente: se sobrescribira en la siguiente ejecucion.

export const generatedSidebar = ${JSON.stringify(generatedSidebar, null, 2)} as const
`

  await fs.writeFile(outputFile, fileContent, 'utf8')
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
